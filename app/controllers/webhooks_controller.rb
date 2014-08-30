class WebhooksController < ApplicationController
  before_filter :authenticate_user!

  include SessionsHelper
  include ApplicationHelper

  def create
    begin
      raise "No camera id specified in request." if params['camera_id'].blank?
      raise "No url specified in request." if params['url'].blank?
      api = get_evercam_api
      response = api.create_webhook(params['camera_id'], params['url'], current_user.username)
      render json: response
      return
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      if error.kind_of?(Evercam::EvercamError)
        flash[:message] = [t("errors.#{error.code}")] unless error.code.nil?
      else
        flash[:message] = ["An error occurred creating your account. Please check "\
                            "the details and try again. If the problem persists, "\
                            "contact support."]
      end
      Rails.logger.error "Exception caught in create webhook request.\nCause: #{error}\n" +
                             error.backtrace.join("\n")
      redirect_to '/'
      return
    end

  end

  def delete
    begin
      raise "No webhook id specified in request." if params['id'].blank?
      api = get_evercam_api
      response = api.delete_webhook(params[:id])
      
      Rails.cache.delete("webhooks/#{response['camera_id']}")
      render json: response
      return
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught deleting webhook.\nCause: #{error}\n" +
                             error.backtrace.join("\n")
      flash[:error] = "An error occurred deleting your webhook. Please try again "\
                      "and, if the problem persists, contact support."
      redirect_to '/'
    end
  end

end
