class PublicController < ApplicationController
  include SessionsHelper
  include ApplicationHelper

  def index
    @user = current_user
    values = {offset: (params[:offset] || 0),
              limit:  (params[:limit] || 100)}
    response = API_call("/public/cameras", :get, values)
    @cameras = []
    if response.success?
      @cameras = JSON.parse(response.body)["cameras"]
    end
    @cameras.delete_if do |camera|
      (camera["extra_urls"].nil? || camera["extra_urls"]["external_jpg_url"].nil?)
    end
  end

  def single
    response = API_call("/cameras/#{params[:id]}", :get)
    if response.success?
      data = JSON.parse(response.body)
      if data.include?("cameras") && data["cameras"].size > 0
        @camera        = data["cameras"][0]
        @camera['jpg'] = "#{EVERCAM_API}cameras/#{@camera['id']}/snapshot.jpg"
      end
    end
  end

end