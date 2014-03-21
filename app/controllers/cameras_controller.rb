require 'typhoeus'


class CamerasController < ApplicationController
  include SessionsHelper
  include ApplicationHelper

  def index
    if current_user.nil?
      redirect_to signin_path
      return
    end
    response  = API_call("users/#{current_user.username}/cameras", :get)
    puts response.body
    puts response.code
    @cameras =  JSON.parse(response.body)['cameras']
    @cameras.each do |c|
      c['jpg'] = "#{EVERCAM_API}cameras/#{c['id']}/snapshot.jpg?api_id=#{current_user.api_id}&api_key=#{current_user.api_key}"
    end
  end

  def new
    @vendors = Default::Vendor.all
    @models = Default::VendorModel.all
  end

  def create
    body = {:id => params['camera-id'],
            :name => params['camera-name'],
            :is_public => false,
            :external_host => params['camera-url'],
            :internal_host => params['local-ip'],
            :external_http_port => params['port'],
            :internal_http_port => params['local-port'],
            :jpg_url => params['snapshot']
    }
    body[:cam_username] = params['camera-username'] unless params['camera-username'].empty?
    body[:cam_password] = params['camera-password'] unless params['camera-password'].empty?
    body[:vendor] = params['camera-vendor'] unless params['camera-vendor'].empty?
    body[:model] = params['camera-model'] unless params['camera-model'].empty?

    response  = API_call('cameras', :post, body)

    if response.success?
      redirect_to "/cameras/#{params['camera-id']}"
    else
      flash[:message] = JSON.parse(response.body)['message']
      @vendors = Default::Vendor.all
      @models = Default::VendorModel.all
      render :new
    end
  end

  def update
    body = {:id => params['camera-id'],
            :name => params['camera-name'],
            :is_public => false,
            :external_host => params['camera-url'],
            :internal_host => params['local-ip'],
            :external_http_port => params['port'],
            :internal_http_port => params['local-port'],
            :jpg_url => params['snapshot'],
            :cam_username => params['camera-username'],
            :cam_password => params['camera-password'],
            :vendor => params['camera-vendor'],
            :model => params['camera-model']
    }

    response  = API_call('cameras', :patch, body)

    if response.success?
      redirect_to "/cameras/#{params['camera-id']}"
    else
      flash[:message] = JSON.parse(response.body)['message']
      response  = API_call("/cameras/#{params[:id]}", :get)
      @camera =  JSON.parse(response.body)['cameras'][0]
      puts @camera
      @camera['jpg'] = "#{EVERCAM_API}cameras/#{@camera['id']}/snapshot.jpg?api_id=#{current_user.api_id}&api_key=#{current_user.api_key}"
      @vendors = Default::Vendor.all
      @models = Default::VendorModel.all
      render :single
    end
  end

  def single
    response  = API_call("/cameras/#{params[:id]}", :get)
    @camera =  JSON.parse(response.body)['cameras'][0]
    @camera['jpg'] = "#{EVERCAM_API}cameras/#{@camera['id']}/snapshot.jpg?api_id=#{current_user.api_id}&api_key=#{current_user.api_key}"
    @vendors = Default::Vendor.all
    @models = Default::VendorModel.all
  end
end
