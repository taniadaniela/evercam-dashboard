class PagesController < ApplicationController
  before_filter :authenticate_user!
  skip_before_action :authenticate_user!, only: [:swagger]
  include SessionsHelper
  include ApplicationHelper
  layout "bare-bones", only: [:swagger, :live]

  def dev
    load_user_cameras
  end

  def location
    @user    = current_user
    @cameras = []
    begin
      @page    = (params[:page].to_i - 1) || 0
      @page = 0 if @page < 0

      output = get_evercam_api.get_public_cameras(thumbnail: true)

      @cameras = output[:cameras]
      @pages = output[:pages]

      @cameras.delete_if do |camera|
        (camera["short"].nil? || camera["short"]["jpg_url"].nil?)
      end
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught fetching a list of public cameras.\nCause: #{error}\n" +
                           error.backtrace.join("\n")
      flash[:error] = "An error occurred fetching the public camera details. Please try "\
                      "again and, if the problem persists, contact support."
    end
  end

  def live
    begin
    api = get_evercam_api
    @camera = api.get_camera(params[:id], true)
    end
    rescue => error
      puts error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught fetching camera details.\nCause: #{error}\n" +
                           error.backtrace.join("\n")
      flash[:error] = "An error occurred fetching the details for your camera. "\
                        "Please try again and, if the problem persists, contact "\
                        "support."
      redirect_to action: 'index'
  end

  def swagger
    response.headers["X-Frame-Options"] = "ALLOWALL"
  end
end
