class PagesController < ApplicationController
  before_filter :authenticate_user!
  skip_before_action :authenticate_user!, only: [:swagger]
  skip_after_filter :intercom_rails_auto_include, only: [:live, :play]
  include SessionsHelper
  include ApplicationHelper

  def dev
    @cameras = load_user_cameras(true, false)
    render layout: "dev"
  end

  def play
    @mp4_url = "http://timelapse.evercam.io/timelapses/#{params[:id]}/archives/#{params[:clip_id]}.mp4"
    render layout: "bare-bones"
  end

  def live
    begin
      api = get_evercam_api
      @camera = api.get_camera(params[:id], true)
    rescue => error
      puts error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught fetching camera details.\nCause: #{error}\n" +
          error.backtrace.join("\n")
      flash[:error] = "An error occurred fetching the details for your camera. "\
                        "Please try again and, if the problem persists, contact "\
                        "support."
      redirect_to cameras_index_path
    end
    render layout: "bare-bones"
  end

  def swagger
    response.headers["X-Frame-Options"] = "ALLOWALL"
    render layout: "swagger"
  end

  def log_and_redirect
    Rails.logger.warn "Old Endpoint Requested: '#{request.original_url}'"
    if current_user
      Rails.logger.warn  "Requester is an User. It's username is '#{current_user.username}' and email is '#{current_user.email}'."
    else
      Rails.logger.warn  "Requester is anonymous."
    end
    Rails.logger.warn  "Request Parameters: #{params.to_hash.inspect}"

    redirect_to root_path
  end
end
