class PublicController < ApplicationController
  before_filter :authenticate_user!

  include SessionsHelper
  include ApplicationHelper

  LIMIT = 1000

  def index
    @user    = current_user
    @cameras = []
    @public_cameras = []
    begin
      load_user_cameras

      @page    = (params[:page].to_i - 1) || 0
      @page = 0 if @page < 0
      offset = @page
      output = get_evercam_api.get_public_cameras(offset: offset,
                                                  thumbnail: true,
                                                  limit: LIMIT)
      @public_cameras = output[:cameras]

      @pages = output[:pages]

      @public_cameras.delete_if do |camera|
        (camera["proxy_url"].nil? || camera["proxy_url"]["jpg"].nil?)
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
      api = get_evercam_api
      @camera = api.get_camera(params[:id])
      @camera['jpg'] = "#{EVERCAM_API}cameras/#{@camera['id']}/snapshot.jpg"
      load_user_cameras
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught fetching the details for a public cameras.\nCause: #{error}\n" +
                         error.backtrace.join("\n")
      flash[:error] = "An error occurred fetching the camera details. Please try "\
                      "again and, if the problem persists, contact support."
      # redirect_to '/public/cameras'
    end
  end

end
