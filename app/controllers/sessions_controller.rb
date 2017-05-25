class SessionsController < ApplicationController
  include SessionsHelper
  include ApplicationHelper

  skip_before_filter :authenticate_user!
  protect_from_forgery except: :destroy
  after_action :allow_iframe, only: [:widget_new, :live_view_private_widget, :hikvision_private_widget, :snapshot_navigator_widget]
  skip_after_filter :intercom_rails_auto_include, only: [:new, :widget_new, :create, :destroy]
  layout "bare-bones"

  def new
    redirect_to cameras_index_path unless current_user.nil?
  end

  def widget_new
    redirect_to cameras_index_path unless current_user.nil?
  end

  def create
    begin
      @user = User.by_login(params[:session][:login].downcase)
    rescue NoMethodError => error
      Rails.logger.error "Error caught fetching user details.\nCause: #{error}\n" + error.backtrace.join("\n")
    end

    if !@user.nil? and @user.password == params[:session][:password]
      sign_in @user
      update_user_intercom(@user)
      if params[:session][:widget].blank?
        if session[:redirect_url]
          url = session[:redirect_url]
          Rails.logger.debug "Redirecting to #{url}."
          session[:redirect_url] = nil
          redirect_to "#{url}#{params[:session][:anchor]}"
        else
          single_camera_redirection(cameras_index_path)
        end
      else
        render json: {success: true}
      end
    else
      Rails.logger.warn "Invalid user name and/or password specified."
      flash.now[:error] = 'Invalid login/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to signin_path
  end
end
