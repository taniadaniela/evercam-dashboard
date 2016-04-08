class CamerasController < ApplicationController
  before_filter :authenticate_user!
  include SessionsHelper
  include ApplicationHelper
  require 'socket'
  require 'timeout'

  def index
    @cameras = load_user_cameras(true, false)
    @show_alert_message = false
    @required_licences = 0
    display_billing_alert if ENV['DISPLAY_BILLING_MESSAGE'].eql?("yes") && current_user.payment_method.eql?(Licence::STRIPE)
  end

  def new
    @cameras = load_user_cameras(true, false)
    @user = (flash[:user] || {})
    @ip = request.remote_ip

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
      if camera.deep_fetch('location') { '' }
        @user['camera-lat'] = camera.deep_fetch('location', 'lat') {}
        @user['camera-lng'] = camera.deep_fetch('location', 'lng') {}
      end
      if camera.deep_fetch('external', 'http', 'jpg') { '' }
        @user['snapshot'] = camera.deep_fetch('external', 'http', 'jpg') { '' }.
          sub("http://#{camera.deep_fetch('external', 'host') { '' }}", '').
          sub(":#{camera.deep_fetch('external', 'http', 'port') { '' }}", '')
      end
    end
  end

  def addcam_test
    @cameras = load_user_cameras(true, false)
    @user = (flash[:user] || {})
    @ip = request.remote_ip

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
      if camera.deep_fetch('location') { '' }
        @user['camera-lat'] = camera.deep_fetch('location', 'lat') {}
        @user['camera-lng'] = camera.deep_fetch('location', 'lng') {}
      end
      if camera.deep_fetch('external', 'http', 'jpg') { '' }
        @user['snapshot'] = camera.deep_fetch('external', 'http', 'jpg') { '' }.
          sub("http://#{camera.deep_fetch('external', 'host') { '' }}", '').
          sub(":#{camera.deep_fetch('external', 'http', 'port') { '' }}", '')
      end
    end
  end

  def create
    camera_id = params['camera-id'].squish if params['camera-id'].present?
    begin
      raise "No camera id specified in request." if camera_id.blank?
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
      body[:location_lat] = params['camera-lat'] unless params['camera-lat'].blank?
      body[:location_lng] = params['camera-lng'] unless params['camera-lng'].blank?
      body[:is_online] = true

      api = get_evercam_api
      api.create_camera(
        params['camera-name'],
        false,
        body,
        camera_id
      )
      redirect_to cameras_single_path(camera_id)
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      flash[:user] = {
        'camera-name' => params['camera-name'],
        'camera-id' => camera_id,
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
      if params["add-camera"].present? && params["add-camera"].eql?("test")
        return redirect_to cameras_new_test_path
      else
        return redirect_to cameras_new_path
      end
    end
    begin
      # Storing snapshot is not essential, so don't show any errors to user
      api.store_snapshot(camera_id, 'Initial snapshot')
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
        :cam_password => params['camera-password'],
        :is_online_email_owner_notification => params['camera-notification'].blank? ? "false" : "true"
      }
      get_evercam_api.update_camera(params['camera-id'], settings)
      flash[:message] = 'Settings updated successfully'
      redirect_to "#{cameras_single_path(params['camera-id'])}/details"
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught updating camera details.\nCause: #{error}\n" +
          error.backtrace.join("\n")
      flash[:message] = "An error occurred updating the details for your camera. "\
                        "Please try again and, if this problem persists, contact "\
                        "support."
      redirect_to "#{cameras_single_path(params['camera-id'])}/details"
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
      @camera['is_online'] = false if @camera['is_online'].blank?
      @camera['timezone'] = 'Etc/UTC' unless @camera['timezone']
      @user_time = Time.new.in_time_zone(@camera['timezone'])
      @selected_date = @user_time.strftime("%m/%d/%Y")
      time_zone = TZInfo::Timezone.get(@camera['timezone'])
      current = time_zone.current_period
      @offset = current.utc_offset + current.std_offset

      params[:from] = (Time.now - 24.hours) if params[:from].blank?
      @share = nil
      if @camera['owner'] != current_user.username
        @share = api.get_camera_share(params[:id], current_user.username)
        return redirect_to cameras_not_found_path if @share.nil? && !@camera['is_public']
        @owner = User.by_login(@camera['owner'])
      else
        @owner = current_user
      end
      @has_edit_rights = @camera["rights"].split(",").include?("edit") if @camera["rights"]
      @camera_shares = api.get_camera_shares(params[:id])
      @share_requests = api.get_camera_share_requests(params[:id], 'PENDING')
      @vendor_model = api.get_model(@camera['model_id']) if @camera['model_id'].present?
      @cloud_recording = api.get_cloud_recordings(params[:id]) if @has_edit_rights
      if @cloud_recording.nil?
        @cloud_recording = {
          "frequency" => 1,
          "status" => "off",
          "storage_duration" => -1,
          "schedule" => {
            "Monday" => ["00:00-23:59"],
            "Tuesday" => ["00:00-23:59"],
            "Wednesday" => ["00:00-23:59"],
            "Thursday" => ["00:00-23:59"],
            "Friday" => ["00:00-23:59"],
            "Saturday" => ["00:00-23:59"],
            "Sunday" => ["00:00-23:59"]
          }
        }
      end
      @motion_detection = api.get_motion_detections(params[:id]) if @has_edit_rights
      if @motion_detection.nil?
        @motion_detection_method = "POST"
        @motion_detection = {
          "enabled" => false,
          "alert_interval_min" => 0,
          "sensitivity" => 0,
          "x1" => 0,
          "x2" => 0,
          "y1" => 0,
          "y2" => 0,
          "schedule" => {},
          "alert_email" => false,
          "emails" => []
        }
      end
      @cameras = load_user_cameras(true, false)
    rescue => error
      if error.try(:status_code).present? && error.status_code.equal?(404)
        redirect_to cameras_not_found_path
      else
        env["airbrake.error_id"] = notify_airbrake(error)
        Rails.logger.error "Exception caught fetching camera details.\nCause: #{error}\n" +
                             error.backtrace.join("\n")
        flash[:error] = "An error occurred fetching the details for your camera. "\
                      "Please try again and, if the problem persists, contact "\
                      "support."
        redirect_to cameras_index_path
      end
    end
  end

  def camera_not_found
    begin
      @cameras = load_user_cameras(true, false)
    rescue => error
      Rails.logger.error "Exception caught fetching user cameras.\nCause: #{error}\n" +
                           error.backtrace.join("\n")
      flash[:error] = "An error occurred fetching user cameras. "\
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

  def request_clip
    result = {success: true}
    begin
      api = get_evercam_api
      camera = api.get_camera(params[:id], true)
      from_date = DateTime.parse(params['from_date']).to_i
      to_date = DateTime.parse(params['to_date']).to_i

      api.create_archive(camera["id"], params["title"], from_date, to_date,
        current_user.username, params["embed_time"], params["is_public"])

      # @time_overlay = params["embed_datetime"] ? "Yes" : "No"
      # UserMailer.create_clip_email(current_user.fullname, "marco@evercam.io",
      #   camera["name"], camera["id"], params["title"], params["from_date"],
      #   params["to_date"], @time_overlay).deliver_now
      result[:message] = "Your clip has been requested."
    rescue => error
      result = {success: false, message: error.message}
    end
    render json: result
  end

  def delete_clip
    result = {success: true}
    begin
      api = get_evercam_api
      api.delete_archive(params[:camera_id], params[:archive_id])
      result[:message] = "Clip deleted successfully."
    rescue => error
      result = {success: false, message: error.message}
    end
    render json: result
  end

  private

  def display_billing_alert
    cloud_recordings = Camera.where(owner: current_user).eager(:cloud_recording).all
    cloud_recordings = cloud_recordings.select { |a| a.cloud_recording.present? && !a.cloud_recording.status.eql?("off") }
    unless cloud_recordings.nil?
      seven_day = thirty_day = ninty_day = infinity = 0
      cloud_recordings.each do |camera|
        if  camera.cloud_recording.storage_duration.equal?(7)
          seven_day = seven_day + 1
        elsif  camera.cloud_recording.storage_duration.equal?(30)
          thirty_day = thirty_day + 1
        elsif  camera.cloud_recording.storage_duration.equal?(90)
          ninty_day = ninty_day + 1
        elsif  camera.cloud_recording.storage_duration.equal?(-1)
          infinity = infinity + 1
        end
      end

      total_required = cloud_recordings.count
      if total_required > 0
        licences = Licence.where(user_id: current_user.id).where(cancel_licence: false)
        valid_seven_day = valid_thirty_day = valid_ninty_day = valid_infinity = 0
        licences.each do |licence|
          if  licence.storage.equal?(7)
            valid_seven_day = valid_seven_day + licence.total_cameras
          elsif  licence.storage.equal?(30)
            valid_thirty_day = valid_thirty_day + licence.total_cameras
          elsif  licence.storage.equal?(90)
            valid_ninty_day = valid_ninty_day + licence.total_cameras
          elsif  licence.storage.equal?(-1)
            valid_infinity = valid_infinity + licence.total_cameras
          end
        end
        total_licences = licences.inject(0) { |sum, a| sum + a.total_cameras }
        if seven_day > valid_seven_day
          @required_licences = @required_licences + (seven_day - valid_seven_day)
          @show_alert_message = true
        end
        if thirty_day > valid_thirty_day
          @required_licences = @required_licences + (thirty_day - valid_thirty_day)
          @show_alert_message = true
        end
        if ninty_day > valid_ninty_day
          @required_licences = @required_licences + (ninty_day - valid_ninty_day)
          @show_alert_message = true
        end
        if infinity > valid_infinity
          @required_licences = @required_licences + (infinity - valid_infinity)
          @show_alert_message = true
        end
      end
    end
  end

  def is_port_open
    begin
      ip = params['ip']
      port = params['port']
      Timeout::timeout(1) do
        begin
          s = TCPSocket.new(ip, port)
          s.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          return false
        end
      end
    rescue Timeout::Error
    end

    return false
  end

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

