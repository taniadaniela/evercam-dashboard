require 'typhoeus'

class CamerasController < ApplicationController
  include SessionsHelper
  include ApplicationHelper

  def index
    if current_user.nil?
      redirect_to :signin_path
      return
    end
    response  = API_call("users/#{current_user.username}/cameras", :get)
    puts response.body
    puts response.code
    @cameras =  JSON.parse(response.body)['cameras']
  end

  def create
    # API request
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

    if response.success?
      redirect_to :cameras_index
    else
      render :new
    end
  end

  def single
    response  = API_call("/cameras/#{params[:id]}", :get)
    puts params
  end
end
