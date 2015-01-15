class PagesController < ApplicationController
  before_filter :authenticate_user!
  skip_before_action :authenticate_user!, only: [:swagger]
  include SessionsHelper
  include ApplicationHelper

  def dev
    @cameras = load_user_cameras(true, false)
  end

  def live
    render layout: "bare-bones"
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
      redirect_to '/'
  end

  def swagger
    render layout: "swagger"
    response.headers["X-Frame-Options"] = "ALLOWALL"
  end
end
