class PublicController < ApplicationController
  include SessionsHelper
  include ApplicationHelper

  def index
    @user    = current_user
    @cameras = []
    begin
      @cameras = get_evercam_api.get_public_cameras(offset: (params[:offset] || 0),
                                                    limit:  (params[:limit] || 100))
      @cameras.delete_if do |camera|
        (camera["extra_urls"].nil? || camera["extra_urls"]["external_jpg_url"].nil?)
      end
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught fetching a list of public cameras.\nCause: #{error}\n" +
                         error.backtrace.join("\n")
      flash[:error] = "An error occurred fetching the public camera details. Please try "\
                      "again and, if the problem persists, contact support."
    end
  end

  def single
    @camera  = nil
    @user    = current_user
    begin
      @camera        = get_evercam_api.get_camera(params[:id])
      @camera['jpg'] = "#{EVERCAM_API}cameras/#{@camera['id']}/snapshot.jpg"
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught fetching the details for a public cameras.\nCause: #{error}\n" +
                         error.backtrace.join("\n")
      flash[:error] = "An error occurred fetching the camera details. Please try "\
                      "again and, if the problem persists, contact support."
    end
  end

end