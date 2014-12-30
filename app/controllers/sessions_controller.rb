class SessionsController < ApplicationController
  include SessionsHelper

  protect_from_forgery except: :destroy
  after_action :allow_iframe, all: :widget_new; :live_view_private_widget; :hikvision_private_widget; :snapshot_navigator_widget

  def new
    unless current_user.nil?
      redirect_to :cameras_index
    end
  end

  def widget_new
    unless current_user.nil?
      redirect_to :cameras_index
    end
  end

  def create
    begin
      @user   = User.by_login(params[:session][:login])
    rescue NoMethodError => error
      Rails.logger.error "Error caught fetching user details.\nCause: #{error}\n" + error.backtrace.join("\n")
    end

    if !@user.nil? and @user.password == params[:session][:password]
      sign_in @user
      if session[:redirect_url]
        url = session[:redirect_url]
        Rails.logger.debug "Redirecting to #{url}."
        session[:redirect_url] = nil
        redirect_to "#{url}#{params[:session][:anchor]}"
      else
        Rails.logger.debug "Redirecting to the cameras index action."
        redirect_to :cameras_index
     end
    else
      Rails.logger.warn "Invalid user name and/or password specified."
      flash.now[:error] = 'Invalid login/password combination' # Not quite right!
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to '/signin'
  end
end
