require 'data_uri'

class CamerasController < ApplicationController
  before_filter :authenticate_user!
  include SessionsHelper
  include ApplicationHelper

  def index
    @cameras = []
    @shares  = []
    response  = API_call("users/#{current_user.username}/cameras", :get)
    if response.success?
      @cameras =  JSON.parse(response.body)['cameras']
      response = API_call("shares/user/#{current_user.username}", :get)
      if response.success?
        list = JSON.parse(response.body)['shares']
        if list && !list.empty?
          camera_ids = []
          list.each {|share| camera_ids << share['camera_id']}
          response = API_call("/cameras", :get, {ids: camera_ids.join(",")})
          @shares = JSON.parse(response.body)['cameras'] if response.success?
        end
      else
        Rails.logger.warn "Request for user camera shares was unsuccessful."
      end
    else
      Rails.logger.warn "Request for user cameras was unsuccessful."
    end
  end

  def new
    @vendors = Vendor.all
    @models  = VendorModel.all
  end

  def jpg
    res  = API_call("cameras/#{params['id']}/snapshot.jpg", :get)
    if res.success?
      response.headers['Content-Type'] = 'image/jpeg'
      render :text => res.body
      return
    else
      res  = API_call("cameras/#{params['id']}/snapshots/latest.json", :get, {}, {:with_data => true})
      if res.success?
        snapshots = JSON.parse(res.body)['snapshots']
        unless snapshots.empty?
          uri = URI::Data.new(snapshots[0]['data'])
          response.headers['Content-Type'] = uri.content_type
          render :text => uri.data
          return
        end
      end
    end
    raise ActionController::RoutingError.new('Not Found')
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
      body[:internal_host] = params['local-ip'] unless params['local-ip'].empty?
      response  = API_call('cameras', :post, body)
    rescue NoMethodError => _
    end

    if response.nil? or not response.success?
      flash[:message] = JSON.parse(response.body)['message'] unless response.nil?
      @vendors = Vendor.all
      @models  = VendorModel.all
      render :new
    elsif response.success?
      redirect_to "/cameras/#{params['camera-id']}"
    end
  end

  def update
    body = {:id => params['camera-id'],
            :name => params['camera-name'],
            :is_public => false,
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
            :model => params['camera-model']
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
      @vendors = Vendor.all
      @models  = VendorModel.all
      response  = API_call("users/#{current_user.username}/cameras", :get)
      if response.success?
        @cameras =  JSON.parse(response.body)['cameras']
      else
        @cameras = []
      end
      render :single
    end
  end
e
  def delete
    response  = API_call("cameras/#{params['id']}", :delete, {})
    if response.success?
      flash[:message] = 'Camera deleted successfully'
      redirect_to "/"
    else
      Rails.logger.info "RESPONSE BODY: '#{response.body}'"
      flash[:message] = JSON.parse(response.body)['message'] unless response.body.blank?
      response  = API_call("cameras/#{params[:id]}", :get)
      @camera =  JSON.parse(response.body)['cameras'][0]
      @vendors = Vendor.all
      @models = VendorModel.all
      render :single
    end
  end

  def single
    response  = API_call("cameras/#{params[:id]}", :get)
    @camera   = JSON.parse(response.body)['cameras'][0]
    response  = API_call("shares/camera/#{params[:id]}", :get)
    @shares   = JSON.parse(response.body)['shares']
    @vendors  = Vendor.all
    @models   = VendorModel.all
    response  = API_call("users/#{current_user.username}/cameras", :get)
    if response.success?
      @cameras =  JSON.parse(response.body)['cameras']
    else
      @cameras = []
    end
  end
end

