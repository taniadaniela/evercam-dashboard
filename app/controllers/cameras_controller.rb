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
      body = {:id => params['camera-id'],
              :name => params['camera-name'],
              :is_public => false,
              :external_host => params['camera-url'],
              :jpg_url => params['snapshot']
      }
      body[:cam_username] = params['camera-username'] unless params['camera-username'].empty?
      body[:cam_password] = params['camera-password'] unless params['camera-password'].empty?
      body[:vendor] = params['camera-vendor'] unless params['camera-vendor'].empty?
      if body[:vendor]
        body[:model] = params["camera-model#{body[:vendor]}"] unless params["camera-model#{body[:vendor]}"].empty?
      end

      body[:internal_http_port] = params['local-http'] unless params['local-http'].empty?
      body[:external_http_port] = params['port'] unless params['port'].empty?
      body[:internal_rtsp_port] = params['local-rtsp'] unless params['local-rtsp'].empty?
      body[:external_rtsp_port] = params['ext-rtsp-port'] unless params['ext-rtsp-port'].empty?
      body[:internal_host] = params['local-ip'] unless params['local-ip'].empty?
      response  = API_call('cameras', :post, body)
    rescue NoMethodError => _
    end

    if response.nil? or not response.success?
      flash[:message] = JSON.parse(response.body)['message'] unless response.nil?
      render :new
    elsif response.success?
      redirect_to "/cameras/#{params['camera-id']}"
    end
  end

  def update
    body = {:id => params['camera-id'],
            :name => params['camera-name'],
            :external_host => params['camera-url'],
            :internal_host => params['local-ip'],
            :external_http_port => params['port'],
            :internal_http_port => params['local-http'],
            :external_rtsp_port => params['ext-rtsp-port'],
            :internal_rtsp_port => params['local-rtsp'],
            :jpg_url => params['snapshot'],
            :cam_username => params['camera-username'],
            :cam_password => params['camera-password'],
            :vendor => params['camera-vendor'],
            :model => params['camera-vendor'].blank? ? '' : params["camera-model#{params['camera-vendor']}"]
    }

    response  = API_call("cameras/#{params['camera-id']}", :patch, body)

    if response.success?
      flash[:message] = 'Settings updated successfully'
      redirect_to "/cameras/#{params['camera-id']}#camera-settings"
    else
      Rails.logger.info "RESPONSE BODY: '#{response.body}'"
      flash[:message] = JSON.parse(response.body)['message'] unless response.body.blank?
      response  = API_call("cameras/#{params[:id]}", :get)
      @camera =  JSON.parse(response.body)['cameras'][0]
      load_cameras_and_shares
      render :single
    end
  end

  def delete
    response = nil
    if [true, "true"].include?(params[:share])
      Rails.logger.debug "Deleting share for camera id '#{params[:id]}'."
      response = API_call("shares/cameras/#{params[:id]}", :delete, share_id: params[:share_id])
    else
      Rails.logger.debug "Deleting camera id '#{params[:id]}'."
      response = API_call("cameras/#{params[:id]}", :delete, {})
    end

    if response.success?
      flash[:message] = "Camera deleted successfully."
      redirect_to '/'
    else
      message = response.body.blank? ? nil : JSON.parse(response.body)['message']
      Rails.logger.error "Camera delete failed. Details: #{message}"
      flash[:message] = (message || "Camera delete failed. Please contact support")
      redirect_to url_for(action: 'single', id: params[:id], share: params[:share])
    end
  end

  def single
    response  = API_call("cameras/#{params[:id]}", :get)
    begin
      output  = JSON.parse(response.body)
      raise "Internal server error. Please contact support." if !output.include?("cameras")
      raise "Unable to find the specified camera." if output["cameras"].size == 0
      @camera = output['cameras'][0]
      @share   = nil
      if @camera['owner'] != current_user.username
        response = API_call("shares", :get, camera_id: params[:id], user_id: current_user.username)
        @share   = JSON.parse(response.body)['shares'][0]
      end
      response        = API_call("shares/cameras/#{params[:id]}", :get)
      @shares         = JSON.parse(response.body)['shares']
      response        = API_call("shares/requests/#{@camera['id']}", :get, status: "PENDING")
      @share_requests = JSON.parse(response.body)['share_requests']
      response  = API_call("users/#{current_user.username}/cameras", :get)
      if response.success?
        @cameras =  JSON.parse(response.body)['cameras']
      else
        @cameras = []
      end
    rescue => error
      Rails.logger.error "Error fetching camera details.\nCause: #{error}\n" + error.backtrace.join("\n")
      flash[:error] = "#{error}"
      redirect_to action: "index"
    end
  end
end

