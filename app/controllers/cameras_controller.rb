require 'typhoeus'

class CamerasController < ApplicationController
  include SessionsHelper
  include ApplicationHelper

  def index
    response  = API_call("users/#{current_user.username}/cameras", :get)
    puts response.body
    puts response.code
    @cameras =  JSON.parse(response.body)['cameras']
  end

  def create
    # API request
    body = {:api_id => current_user.api_id,
            :api_key => current_user.api_key,
            :id => params['camera-id'],
            :name => params['camera-name'],
            :is_public => false,
            :cam_username => params['camera-username'],
            :cam_password => params['camera-password'],
            :external_url => params['camera-url'].clone,
            :jpg_url => params['snapshot']
    }
    body[:external_url] << ':' << params['port'] if params['port']

    response  = API_call('cameras', :post, body)

    if response.success?
      redirect_to :cameras_index
    else
      render :new
    end
  end

  def single

  end
end
