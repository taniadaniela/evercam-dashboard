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
            :external_url => 'http://' + params['camera-url'].clone,
            :jpg_url => params['snapshot']
    }
    body[:cam_username] = params['camera-username'] unless params['camera-username'].empty?
    body[:cam_password] = params['camera-password'] unless params['camera-password'].empty?
    body[:vendor] = params['camera-vendor'] unless params['camera-vendor'].empty?
    body[:model] = params['camera-model'] unless params['camera-model'].empty?
    body[:external_url] << ':' << params['port'] if params['port']
    unless params['local-ip'].empty?
      body[:internal_url] = 'http://' + params['local-ip'].clone
      body[:internal_url] << ':' << params['local-port'] if params['local-port']
    end


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

  def single
    response  = API_call("/cameras/#{params[:id]}", :get)
    @camera =  JSON.parse(response.body)['cameras'][0]
    @camera['jpg'] = "#{EVERCAM_API}cameras/#{@camera['id']}/snapshot.jpg?api_id=#{current_user.api_id}&api_key=#{current_user.api_key}"
    @vendors = Default::Vendor.all
    @models = Default::VendorModel.all
  end
end
