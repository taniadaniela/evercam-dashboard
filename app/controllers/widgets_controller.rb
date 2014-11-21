class WidgetsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :allow_iframe, only: :live_view_private_widget; :hikvision_private_widget; :snapshot_navigator_widget
  after_action :allow_iframe, only: :hikvision_private_widget; :snapshot_navigator_widget
  before_action :allow_iframe, only: :snapshot_navigator_widget
  before_filter :normal_cookies_for_ie_in_iframes!, only: :live_view_private_widget; :hikvision_private_widget; :snapshot_navigator_widget
  skip_before_action :verify_authenticity_token, only: [:live_view_widget, :hikvision_local_storage, :snapshot_navigator, :live_view_private_widget, :hikvision_private_widget, :snapshot_navigator_widget]
  skip_before_action :authenticate_user!, only: [:live_view_widget, :hikvision_local_storage, :snapshot_navigator, :live_view_private_widget, :hikvision_private_widget, :snapshot_navigator_widget]
  skip_after_filter :intercom_rails_auto_include, only: [:live_view_widget, :hikvision_local_storage, :snapshot_navigator, :live_view_private_widget, :hikvision_private_widget, :snapshot_navigator_widget]

  include SessionsHelper
  include ApplicationHelper

  def widgets
    current_user
  end

  def widgets_new
    current_user
    load_user_cameras
  end

  def widgets_hikvision
    current_user
    load_user_cameras
  end

  def live_view_widget
    respond_to do |format|
      format.js { render :file => "widgets/live.view.widget.js", :mime_type => Mime::Type.lookup('text/javascript')}
    end
  end

  def hikvision_local_storage
    respond_to do |format|
      format.js { render :file => "widgets/hikvision.local.storage.js", :mime_type => Mime::Type.lookup('text/javascript')}
    end
  end

  def live_view_private_widget
    check_user_login(false)

    begin
      api = get_evercam_api
      api.get_snapshot(params[:camera])
    rescue => error
      @unathorized = error.status_code == 403
      @not_exist = error.status_code == 404
    end
    render :layout => false
  end

  def hikvision_private_widget
    check_user_login(true)
  end

  def widget_snapshot_navigator
    current_user
    load_user_cameras
  end

  def snapshot_navigator
    respond_to do |format|
      format.js { render :file => "widgets/snapshot.navigator.widget.js", :mime_type => Mime::Type.lookup('text/javascript')}
    end
  end

  def snapshot_navigator_widget
    begin
      check_user_login(false)

      api               = get_evercam_api
      @camera           = Hashie::Mash.new(api.get_camera(params[:camera], true))
      @camera['timezone'] = 'Etc/GMT+1' unless @camera['timezone']
      time_zone         = TZInfo::Timezone.get(@camera['timezone'])
      current           = time_zone.current_period
      @offset           = current.utc_offset + current.std_offset

      render :layout => false
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught in snapshot navigator.\nCause: #{error}\n" +
                             error.backtrace.join("\n")
      flash[:message] = error.message
    end
  end

  private

  def check_user_login(is_hikvision_widget)
    widget_user = nil
    unless params[:api_id].blank? or params[:api_key].blank?
      widget_user = User.where(api_id: params[:api_id], api_key: params[:api_key]).first
      sign_in(widget_user) if widget_user
    end
    if current_user.nil? and widget_user.nil?
      session[:redirect_url] = request.original_url
      redirect_to '/widget_signin'
      return
    end
    if(is_hikvision_widget)
      render :layout => false
    end
  end

end
