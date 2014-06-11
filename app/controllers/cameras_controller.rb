require 'data_uri'

class CamerasController < ApplicationController
  before_filter :authenticate_user!
  include SessionsHelper
  include ApplicationHelper

  def index
    load_cameras_and_shares
  end

  def new
  end

  def create
    response = nil
    begin
      raise "No camera id specified in request." if params['camera-id'].blank?
      raise "No camera name specified in request." if params['camera-name'].blank?

      body = {:external_host => params['camera-url'],
              :jpg_url => params['snapshot']}
      body[:cam_username] = params['camera-username'] unless params['camera-username'].blank?
      body[:cam_password] = params['camera-password'] unless params['camera-password'].blank?
      body[:vendor] = params['camera-vendor'] unless params['camera-vendor'].blank?
      if body[:vendor]
        body[:model] = params["camera-model#{body[:vendor]}"] unless params["camera-model#{body[:vendor]}"].blank?
      end

      body[:internal_http_port] = params['local-http'] unless params['local-http'].blank?
      body[:external_http_port] = params['port'] unless params['port'].blank?
      body[:internal_rtsp_port] = params['local-rtsp'] unless params['local-rtsp'].blank?
      body[:external_rtsp_port] = params['ext-rtsp-port'] unless params['ext-rtsp-port'].blank?
      body[:internal_host] = params['local-ip'] unless params['local-ip'].blank?
      body[:is_online] = true

      api = get_evercam_api
      api.create_camera(params['camera-id'],
                        params['camera-name'],
                        false,
                        body)
      api.store_snapshot(params['camera-id'], 'Initial snapshot')
      redirect_to action: 'single', id: params['camera-id']
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught in create camera request.\nCause: #{error}\n" +
                         error.backtrace.join("\n")
      flash[:message] = "An error occurred creating your new camera. Please try "\
                        "again and, if the problem persists, contact support."
      redirect_to action: 'new'
    end
  end

  def update
    begin
      settings = {:name => params['camera-name'],
                  :external_host => params['camera-url'],
                  :internal_host => params['local-ip'],
                  :external_http_port => params['port'],
                  :internal_http_port => params['local-http'],
                  :external_rtsp_port => params['ext-rtsp-port'],
                  :internal_rtsp_port => params['local-rtsp'],
                  :jpg_url => params['snapshot'],
                  :vendor => params['camera-vendor'],
                  :model => params['camera-vendor'].blank? ? '' : params["camera-model#{params['camera-vendor']}"],
                  :cam_username => params['camera-username'],
                  :cam_password => params['camera-password']}

      api = get_evercam_api
      api.update_camera(params['camera-id'], settings)
      flash[:message] = 'Settings updated successfully'
      redirect_to "/cameras/#{params['camera-id']}#camera-settings"
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught updating camera details.\nCause: #{error}\n" +
                         error.backtrace.join("\n")
      flash[:message] = "An error occurred updating the details for your camera. "\
                        "Please try again and, if this problem persists, contact "\
                        "support."
      redirect_to action: 'single', id: params['camera-id']
    end
  end

  def delete
    begin
      api = get_evercam_api
      if [true, "true"].include?(params[:share])
        Rails.logger.debug "Deleting share for camera id '#{params[:id]}'."
        api.delete_camera_share(params[:id], params[:share_id])
      else
        Rails.logger.debug "Deleting camera id '#{params[:id]}'."
        api.delete_camera(params[:id])
      end
      flash[:message] = "Camera deleted successfully."
      redirect_to '/'
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught deleting camera.\nCause: #{error}\n" +
                         error.backtrace.join("\n")
      flash[:error] = "An error occurred deleting your camera. Please try again "\
                      "and, if the problem persists, contact support."
      redirect_to action: 'single', id: params[:id], share: params[:share]
    end
  end

  def single
    begin
      api               = get_evercam_api
      @camera           = api.get_camera(params[:id])
      @page             = (params[:page].to_i - 1) || 0
      @types            = ['created', 'accessed', 'viewed', 'edited', 'captured',
                           'shared', 'stopped sharing', 'online', 'offline']
      parameters        = {objects: true, page: @page, types: params[:types]}
      parameters[:from] = params[:from] if !params[:from].blank?
      parameters[:to]   = params[:to] if !params[:to].blank?
      output            = api.get_logs(params[:id], parameters)
      @logs             = output[:logs]
      @pages            = output[:pages]
      @share  = nil
      if @camera['owner'] != current_user.username
        @share = api.get_camera_share(params[:id], current_user.username)
      end
      @share_requests = api.get_camera_share_requests(params[:id], 'PENDING')
      load_cameras_and_shares
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught fetching camera details.\nCause: #{error}\n" +
                         error.backtrace.join("\n")
      flash[:error] = "An error occurred fetching the details for your camera. "\
                      "Please try again and, if the problem persists, contact "\
                      "support."
      redirect_to action: 'index'
    end
  end

  def transfer
    result = {success: true}
    begin
      raise BadRequestError.new("No camera id specified in request.") if !params.include?(:camera_id)
      raise BadRequestError.new("No user email specified in request.") if !params.include?(:email)
      get_evercam_api.change_camera_owner(params[:camera_id], params[:email])
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught transferring camera ownership.\nCause: #{error}\n" +
                         error.backtrace.join("\n")
      message = "An error occurred transferring ownership of this camera. Please "\
                "try again and, if the problem persists, contact support."
      result  = {success: false, message: message, error: "#{error}"}
    end
    render json: result
  end
end

