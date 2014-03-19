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

  def create
    API request
    body = {:id => params['camera-id'],
            :name => params['camera-name'],
            :is_public => false,
            :external_url => 'http://' + params['camera-url'].clone,
            :jpg_url => params['snapshot']
    }
    body[:cam_username] = params['camera-username'] unless params['camera-username'].empty?
    body[:cam_password] = params['camera-password'] unless params['camera-password'].empty?
    body[:external_url] << ':' << params['port'] if params['port']

    response  = API_call('cameras', :post, body)

    puts response.body
    puts response.code
    if true
      redirect_to "/cameras/#{params['camera-id']}"
    else
      render :new
    end
  end

  def single
    response  = API_call("/cameras/#{params[:id]}", :get)
    puts params
  end
end
