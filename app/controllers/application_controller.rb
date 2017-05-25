class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  prepend_before_filter :authenticate_user!, :set_cache_buster
  rescue_from Exception, :with => :render_error if Rails.env.production?
  helper_method :intercom_key

  def authenticate_user!
    if current_user.nil? or (params.has_key?(:api_id) and params.has_key?(:api_key))
      user = nil
      redirect_url = request.original_url
      if params.has_key?(:api_id) and params.has_key?(:api_key)
        user = User.where(api_id: params[:api_id], api_key: params[:api_key]).first
      end

      if user.nil?
        session[:redirect_url] = redirect_url
        redirect_to signin_path
      else
        sign_in user
        update_user_intercom(user)
        single_camera_redirection(redirect_url)
      end
    end
  end

  def update_user_intercom(user)
    if Evercam::Config.env == :production
      intercom = Intercom::Client.new(
        app_id: Evercam::Config[:intercom][:app_id],
        api_key: Evercam::Config[:intercom][:api_key]
      )
      begin
        ic_user = intercom.users.find(:user_id => user.username)
      rescue
        # Intercom::ResourceNotFound
        # Ignore it
      end
      unless ic_user.nil?
        begin
          ic_user.user_id = user.username if ic_user.user_id.nil?
          ic_user.email = user.email
          ic_user.name = user.fullname
          ic_user.signed_up_at = user.created_at.to_i if ic_user.signed_up_at
          ic_user.last_seen_user_agent = request.user_agent
          ic_user.last_request_at = Time.now.to_i
          ic_user.new_session = true
          ic_user.last_seen_ip = request.remote_ip
          intercom.users.save(ic_user)
        rescue
          # Ignore it
        end
      end
    end
  end

  def owns_data!
    if current_user.username != params[:id]
      sign_out
      redirect_to signin_path
    end
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def load_user_cameras(shared, thumbnail)
    api = get_evercam_api
    begin
      api.get_user_cameras(current_user.username, shared, thumbnail) if @cameras.blank?
    rescue => error
      Rails.logger.error "Exception caught fetching user cameras.\nCause: #{error}"
      []
    end
  end

  # Added before_action to decouple @cameras from users controller
  def ensure_cameras_loaded
    if @cameras.nil?
      load_user_cameras(true, false)
    end
  end

  def set_prices
    @prices = Prices.new
  end

  def is_stripe_customer?
    current_user.stripe_customer_id.present?
  rescue
    return false
  end
  helper_method :is_stripe_customer?

  # Started to move some methods from helper to application controller because
  # helpers should not make calls to db/API calls
  def retrieve_stripe_subscriptions
    if is_stripe_customer?
      @subscriptions = Stripe::Customer.retrieve(current_user.stripe_customer_id).subscriptions.all
    end
  end

  def current_subscription
    if current_user.stripe_customer_id.present?
      customer = StripeCustomer.new(current_user.stripe_customer_id)
      subscription = customer.current_plan ? customer.current_plan : false
    else
      false
    end
  end

  def retrieve_plans_quantity(subscriptions)
    @twenty_four_hours_recording = 0
    @twenty_four_hours_recording_annual = 0
    @seven_days_recording = 0
    @seven_days_recording_annual = 0
    @thirty_days_recording = 0
    @thirty_days_recording_annual = 0
    @ninety_days_recording = 0
    @ninety_days_recording_annual = 0
    @infinity = 0
    @infinity_annual = 0
    if subscriptions.present?
      subscriptions[:data].each do |subscription|
        case subscription.plan.id
        when "24-hours-recording"
          @twenty_four_hours_recording = @twenty_four_hours_recording + subscription.quantity
        when "24-hours-recording-annual"
          @twenty_four_hours_recording_annual = @twenty_four_hours_recording_annual + subscription.quantity
        when "7-days-recording"
          @seven_days_recording = @seven_days_recording + subscription.quantity
        when "7-days-recording-annual"
          @seven_days_recording_annual = @seven_days_recording_annual + subscription.quantity
        when "30-days-recording"
          @thirty_days_recording = @thirty_days_recording + subscription.quantity
        when "30-days-recording-annual"
          @thirty_days_recording_annual = @thirty_days_recording_annual + subscription.quantity
        when "90-days-recording"
          @ninety_days_recording = @ninety_days_recording + subscription.quantity
        when "90-days-recording-annual"
          @ninety_days_recording_annual = @ninety_days_recording_annual + subscription.quantity
        when "infinity"
          @infinity = subscription.quantity
        when "infinity-annual"
          @infinity_annual = subscription.quantity
        end
      end
    end
  end

  def intercom_key
    "#{ENV['INTERCOM_APP_ID']}"
  end

  private

  def render_error(exception)
    if exception.message.eql?("ActionController::InvalidAuthenticityToken")
      redirect_to signin_path
    else
      render :file => "#{Rails.root}/public/500.html", :layout => false, :status => 500
    end
  end
end
