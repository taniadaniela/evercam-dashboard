class PublicController < ApplicationController
  include SessionsHelper
  include ApplicationHelper

  def index
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
    @camera = Camera.where(exid: params[:id]).first
    @camera['jpg'] = "#{EVERCAM_API}cameras/#{@camera.exid}/snapshot.jpg"
  end

end