class PagesController < ApplicationController
  include SessionsHelper
  include ApplicationHelper
  layout "forswagger", only: [:swagger]

  def dev
    current_user
  end

  def add_android
    current_user
  end

  def widgets
    current_user
  end

  def widgets_new
    current_user

    @cameras = []
    @shares  = []
    response  = API_call("users/#{current_user.username}/cameras", :get)
    if response.success?
      @cameras =  JSON.parse(response.body)['cameras']
      response = API_call("shares/user/#{current_user.username}", :get)
      if response.success?
        @shares = JSON.parse(response.body)['shares']
      else
        Rails.logger.warn "Request for user camera shares was unsuccessful."
      end
    else
      Rails.logger.warn "Request for user cameras was unsuccessful."
    end
  end

  def swagger
    response.headers["X-Frame-Options"] = "ALLOWALL"
    current_user
  end

end