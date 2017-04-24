class PagesController < ApplicationController
  before_filter :authenticate_user!
  skip_after_filter :intercom_rails_auto_include, only: [:live, :play]
  skip_before_action :authenticate_user!, only: [:revoke_request, :unsubscribe, :unsubscribed, :good_bye]
  include SessionsHelper
  include ApplicationHelper

  def revoke_request
    @camera_id = params["id"]
    render layout: "bare-bones"
  end

  def unsubscribe
    begin
      @id = params["id"]
      @email = params["email"]
    rescue => error
      if error.try(:status_code).present? && error.status_code.equal?(404)
        @message = "Snapmail '#{params["id"]}' does not exists."
      else
        @message = error.message
      end
    end
    render layout: "bare-bones"
  end

  def unsubscribed
    begin
      id = params["id"]
      email = params["email"]
      get_evercam_api.unsubscribe_snapmail(id, email)
    rescue => error
      flash[:message] = error.message
    end
    render layout: "bare-bones"
  end

  def play
    @mp4_url = "#{EVERCAM_MEDIA_API}cameras/#{params[:id]}/archives/#{params[:clip_id]}/play?"\
               "api_id=#{current_user.api_id}&api_key=#{current_user.api_key}"
    archive_date = Date.parse(params["date"])
    if archive_date < Date.parse("2017-01-31")
      @mp4_url = "http://timelapse.evercam.io/timelapses/#{params[:id]}/archives/#{params[:clip_id]}.mp4"
    end
    render layout: "bare-bones"
  end

  def live
    begin
      api = get_evercam_api
      @camera = api.get_camera(params[:id], true)
      render layout: "bare-bones"
    rescue => error
      puts error
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

  def good_bye
    render layout: "bare-bones"
  end
end
