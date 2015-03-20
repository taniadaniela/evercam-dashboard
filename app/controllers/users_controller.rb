class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :owns_data!
  before_action :retrieve_stripe_customer
  before_filter :retrieve_stripe_subscriptions
  before_filter :retrieve_add_ons, except: [:new, :create]
  skip_before_action :authenticate_user!, only: [:new, :create, :confirm,
                     :password_reset_request, :password_update, :password_update_form]
  skip_before_action :owns_data!, only: [:new, :create, :confirm,
                     :password_reset_request, :password_update, :password_update_form]
  layout "bare-bones", except: [:settings]

  include SessionsHelper
  include ApplicationHelper
  include StripeCustomersHelper
  require "stripe"
  require "date"

  def new
    if params[:key] && current_user
      sign_out
    end
    unless current_user.nil?
      return redirect_to cameras_index_path
    end
    @share_request = nil
    if params[:key]
      @share_request = CameraShareRequest.where(
        status: CameraShareRequest::PENDING,
        key: params[:key]
      ).first
      unless @share_request.nil?
        user = User.where(email: @share_request.email.downcase).first
        unless user.blank?
          flash[:error] = "You've already registered with this email #{@share_request.email.downcase} address."
          redirect_to signin_path
        end
      end
    end
    if request.location
      params[:user] = { 'country'=> request.location.country_code }
    end
  end

  def create
    user = params[:user]
    begin
      if user.nil?
        raise "No user details specified in request."
      end
      get_evercam_api.create_user(
        user['firstname'],
        user['lastname'],
        user['username'],
        user['email'],
        user['password'],
        user['country'],
        params[:key]
      )

      user = User.where(email: user[:email].downcase).first
      sign_in user
      redirect_to cameras_index_path
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      if error.kind_of?(Evercam::EvercamError)
        flash[:message] = t("errors.#{error.code}") unless error.code.nil?
        assess_field_errors(error)
      else
        flash[:message] = "An error occurred creating your account. Please check "\
                            "the details and try again. If the problem persists, "\
                            "contact support."
      end
      Rails.logger.error "Exception caught in create user request.\nCause: #{error}\n" +
          error.backtrace.join("\n")
      render action: 'new', user: user
    end
  end

  def confirm
    user = User.where(Sequel.expr(email: params[:u]) | Sequel.expr(username: params[:u])).first
    unless user.nil?
      code = Digest::SHA1.hexdigest(user.username + user.created_at.to_s)
      if params[:c] == code
        user.confirmed_at = Time.now
        user.save
        flash[:notice] = 'Successfully activated your account'
      else
        flash[:notice] = 'Activation code is incorrect'
      end
    end
    redirect_to signin_path
  end
 
  def settings
    @cameras = load_user_cameras(true, false)
    @countries = Country.all
    unless current_user.billing_id.blank?
      @credit_cards = retrieve_credit_cards
      @subscriptions = has_subscriptions? ? retrieve_stripe_subscriptions : nil
    end
  end

  def settings_update
    begin
      parameters = {}
      parameters[:firstname] = params['user-firstname'] if params.include?('user-firstname')
      parameters[:lastname] = params['user-lastname'] if params.include?('user-lastname')
      parameters[:country] = params['country'] if params.include?('country')
      if params.include?('email')
        parameters[:email] = params['email'] unless params['email'] == current_user.email
      end
      if !parameters.empty?
        get_evercam_api.update_user(current_user.username, parameters)
        session[:user] = User.by_login(current_user.username).email
        refresh_user
      end
      flash[:message] = 'Settings updated successfully'
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught in update user request.\nCause: #{error}\n" +
          error.backtrace.join("\n")
      if error.kind_of?(Evercam::EvercamError)
        if error.code
          flash[:message] = t("errors.#{error.code}")
          assess_field_errors(error)
        else
          flash[:message] = "An error occurred updating your details. Please try "\
          "again and, if the problem persists, contact support."
        end
      else
        flash[:message] = "An error occurred updating your details. Please try "\
                        "again and, if the problem persists, contact support."
      end
    end
    redirect_to action: 'settings'
  end

  def password_reset_request
    email = params[:email]
    unless email.nil?
      user = User.by_login(email)

      if user
        t = Time.now
        if user.reset_token.present? and user.token_expires_at.present? and user.token_expires_at > t
          expires = user.token_expires_at
          token = user.reset_token
        else
          expires = t + 24.hour
          token = SecureRandom.hex(16)
        end

        user.update(reset_token: token, token_expires_at: expires)

        UserMailer.password_reset(email, user, token).deliver_now
        flash.now[:message] = "We’ve sent you an email with instructions for changing your password."
      else
        flash.now[:message] = "Email address not found."
      end
    end
  end

  def password_update_form
    username = params[:u]
    user = User.by_login(username)
    if user.nil? or user.token_expires_at.blank? or user.token_expires_at < Time.now
      @expired = true
    else
      @expired = false
    end
    render "password_update"
  end

  def password_update
    token = params[:token]
    username = params[:username]
    user = User.by_login(username)
    if user.nil? or token != user.reset_token or user.token_expires_at < Time.now
      flash[:message] = 'Invalid username or token'
    else
      user.update(reset_token: '', token_expires_at: Time.now)
      user.password = params[:password]
      user.save
      sign_in user
      redirect_to cameras_index_path, message: 'Your password has been changed'
    end
  end

  def resend_confirmation_email
    user = User.where(Sequel.expr(username: params[:id])).first
    unless user.nil?
      code = Digest::SHA1.hexdigest(user.username + user.created_at.to_s)
      UserMailer.resend_confirmation_email(user, code).deliver_now
      flash[:message] = 'We’ve sent you a confirmation email with instructions.'
    else
      flash[:message] = t("errors.user_not_found_error")
    end
    redirect_to user_path(user.username)
  end

  private

  def assess_field_errors(error)
    field_errors = {}
    case error.code
      when "duplicate_email_error"
        field_errors["email"] = t("errors.email_field_duplicate")
      when "duplicate_username_error"
        field_errors["username"] = t("errors.username_field_duplicate")
      when "invalid_country_error"
        field_errors["country"] = t("errors.country_field_invalid")
      when "unknown_error"
        field_errors["unknown"] = t("errors.unknown_error")
      when "invalid_parameters"
        error.context.each {|field| field_errors[field] = t("errors.#{field}_field_invalid")}
    end
    flash[:field_errors] = field_errors
  end
end
