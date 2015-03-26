class CamerasController < ApplicationController
  before_filter :authenticate_user!
  include SessionsHelper
  include ApplicationHelper
  require("open-uri")

  def index
    @cameras = load_user_cameras(true, false) 
  end

  def new
    @cameras = load_user_cameras(true, false)
    @user = (flash[:user] || {})

    @ip = open("http://api.ipify.org").read

    if @user == {} && params[:id]
      camera = get_evercam_api.get_camera(params[:id], false)
      @user['camera-name'] = camera['name']
      @user['camera-id'] = camera['id']
      @user['camera-username'] = camera['cam_username']
      @user['camera-password'] = camera['cam_password']
      @user['camera-url'] = camera.deep_fetch('external', 'host')
      @user['port'] = camera.deep_fetch('external', 'http', 'port') {}
      @user['ext-rtsp-port'] = camera.deep_fetch('external', 'rtsp', 'port') {}
      @user['camera-vendor'] = camera['vendor_id']
      @user['camera-model'] = camera['model_id']
      @user['local-ip'] = camera.deep_fetch('internal', 'host') {}
      @user['local-http'] = camera.deep_fetch('internal', 'http', 'port') {}
      @user['local-rtsp'] = camera.deep_fetch('internal', 'rtsp', 'port') {}
      if camera.deep_fetch('external', 'http', 'jpg') { '' }
        @user['snapshot'] = camera.deep_fetch('external', 'http', 'jpg') { '' }.
          sub("http://#{camera.deep_fetch('external', 'host') { '' }}", '').
          sub(":#{camera.deep_fetch('external', 'http', 'port') { '' }}", '')
      end
    end
  end

  def create
    begin
      raise "No camera id specified in request." if params['camera-id'].blank?
      raise "No camera name specified in request." if params['camera-name'].blank?

      body = {external_host: params['camera-url'], jpg_url: params['snapshot']}
      body[:cam_username] = params['camera-username'] unless params['camera-username'].blank?
      body[:cam_password] = params['camera-password'] unless params['camera-password'].blank?
      body[:vendor] = params['camera-vendor'] unless params['camera-vendor'].blank?
      body[:model] = params["camera-model"] unless params["camera-model"].blank? if body[:vendor]

      body[:internal_http_port] = params['local-http'] unless params['local-http'].blank?
      body[:external_http_port] = params['port'] unless params['port'].blank?
      body[:internal_rtsp_port] = params['local-rtsp'] unless params['local-rtsp'].blank?
      body[:external_rtsp_port] = params['ext-rtsp-port'] unless params['ext-rtsp-port'].blank?
      body[:internal_host] = params['local-ip'] unless params['local-ip'].blank?
      body[:is_online] = true

      api = get_evercam_api
      api.create_camera(
        params['camera-name'],
        false,
        body,
        params['camera-id']
      )
      redirect_to cameras_single_path(params['camera-id'])
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      flash[:user] = {
        'camera-name' => params['camera-name'],
        'camera-id' => params['camera-id'],
        'camera-username' => params['camera-username'],
        'camera-password' => params['camera-password'],
        'camera-url' => params['camera-url'],
        'port' => params['port'],
        'ext-rtsp-port' => params['ext-rtsp-port'],
        'snapshot' => params['snapshot'],
        'camera-vendor' => params['camera-vendor'],
        'camera-model' => params['camera-model'],
        'local-ip' => params['local-ip'],
        'local-http' => params['local-http'],
        'local-rtsp' => params['local-rtsp']
      }
      if error.kind_of?(Evercam::EvercamError)
        flash[:message] = t("errors.#{error.code}") unless error.code.nil?
        assess_field_errors(error)
      else
        flash[:message] = "An error occurred creating your account. Please check "\
                          "the details and try again. If the problem persists, "\
                          "contact support."
      end
      Rails.logger.error "Exception caught in create camera request.\nCause: #{error}\n" +
          error.backtrace.join("\n")
      return redirect_to cameras_new_path
    end
    begin
      # Storing snapshot is not essential, so don't show any errors to user
      api.store_snapshot(params['camera-id'], 'Initial snapshot')
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
    end
  end

  def update
    begin
      settings = {
        :name => params['camera-name'],
        :external_host => params['camera-url'],
        :timezone => params['camera-timezone'].blank? ? 'Etc/UTC' : ActiveSupport::TimeZone.new(params['camera-timezone']).tzinfo.name,
        :internal_host => params['local-ip'],
        :external_http_port => params['port'],
        :internal_http_port => params['local-http'],
        :external_rtsp_port => params['ext-rtsp-port'],
        :internal_rtsp_port => params['local-rtsp'],
        :jpg_url => params['snapshot'],
        :vendor => params['camera-vendor'],
        :model => params['camera-vendor'].blank? ? '' : params['camera-model'],
        :location_lat => params['cameraLat'],
        :location_lng => params['cameraLng'],
        :cam_username => params['camera-username'],
        :cam_password => params['camera-password']
      }

      get_evercam_api.update_camera(params['camera-id'], settings)
      flash[:message] = 'Settings updated successfully'
      redirect_to cameras_single_path(params['camera-id'])
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught updating camera details.\nCause: #{error}\n" +
          error.backtrace.join("\n")
      flash[:message] = "An error occurred updating the details for your camera. "\
                        "Please try again and, if this problem persists, contact "\
                        "support."
      redirect_to cameras_single_path(params['camera-id'])
    end
  end

  def delete
    begin
      result = {success: true}
      api = get_evercam_api
      if [true, "true"].include?(params[:share])
        api.delete_camera_share(params[:id], current_user.email)
      else
        if params[:camera_specified_id] && params[:camera_specified_id] == params[:id]
          api.delete_camera(params[:id])
        else
          result = {success: false, message: "Invalid camera id specified."}
        end
      end
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught deleting camera.\nCause: #{error}\n" +
          error.backtrace.join("\n")
      message = "An error occurred deleting your camera. Please try again "\
                      "and, if the problem persists, contact support."
      result = {success: false, message: message}
    end
    render json: result
  end

  def single
    begin
      api = get_evercam_api
      @camera = api.get_camera(params[:id], true)
      @page = (params[:page].to_i - 1) || 0
      @types = ['created', 'accessed', 'viewed', 'edited', 'captured',
        'shared', 'stopped sharing', 'online', 'offline']
      @camera['timezone'] = 'Etc/UTC' unless @camera['timezone']
      @selected_date = Time.new.in_time_zone(@camera['timezone']).strftime("%m/%d/%Y")
      time_zone = TZInfo::Timezone.get(@camera['timezone'])
      current = time_zone.current_period
      @offset = current.utc_offset + current.std_offset

      params[:from] = (Time.now - 24.hours) if params[:from].blank?
      @share = nil
      if @camera['owner'] != current_user.username
        @share = api.get_camera_share(params[:id], current_user.username)
        return redirect_to cameras_index_path if @share.nil?
        @owner_email = User.by_login(@camera['owner']).username
      else
        @owner_email = current_user.username
      end
      @has_edit_rights = @camera["rights"].split(",").include?("edit") if @camera["rights"]
      @camera_shares = api.get_camera_shares(params[:id])
      @share_requests = api.get_camera_share_requests(params[:id], 'PENDING')
      @webhooks = api.get_webhooks(params[:id])
      @cameras = load_user_cameras(true, false)
    rescue => error
      puts error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught fetching camera details.\nCause: #{error}\n" +
          error.backtrace.join("\n")
      flash[:error] = "An error occurred fetching the details for your camera. "\
                      "Please try again and, if the problem persists, contact "\
                      "support."
      redirect_to cameras_index_path
    end
  end

  def transfer
    result = {success: true}
    begin
      raise BadRequestError.new("No camera id specified in request.") unless params.include?(:camera_id)
      raise BadRequestError.new("No user email specified in request.") unless params.include?(:email)
      get_evercam_api.change_camera_owner(params[:camera_id], params[:email])
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught transferring camera ownership.\nCause: #{error}\n" +
          error.backtrace.join("\n")
      message = "An error occurred transferring ownership of this camera. Please "\
                "try again and, if the problem persists, contact support."
      result = {success: false, message: message, error: "#{error}"}
    end
    render json: result
  end

  private

  def assess_field_errors(error)
    field_errors = {}
    case error.code
      when "vendor_not_found_error"
        field_errors["username"] = t("errors.invalid_vendor_error")
      when "model_not_found_error"
        field_errors["model"] = t("errors.invalid_model_error")
      when "duplicate_camera_id_error"
        field_errors["id"] = t("errors.#{error.code}")
      when "invalid_parameters"
        error.context.each { |field| field_errors[field] = t("errors.#{field}_field_invalid") }
    end
    flash[:field_errors] = field_errors
  end
end

