class PagesController < ApplicationController
  before_filter :authenticate_user!
  skip_after_filter :intercom_rails_auto_include, only: [:live, :play]
  skip_before_action :authenticate_user!, only: :revoke_request
  include SessionsHelper
  include ApplicationHelper

  def revoke_request
    @camera_id = params["id"]
    render layout: "bare-bones"
  end

  def play
    @mp4_url = "http://timelapse.evercam.io/timelapses/#{params[:id]}/archives/#{params[:clip_id]}.mp4"
    render layout: "bare-bones"
  end

  def live
    begin
      api = get_evercam_api
      @camera = api.get_camera(params[:id], true)
      render layout: "bare-bones"
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
