class UsersController < ApplicationController
  before_filter :authenticate_user!
  skip_before_action :authenticate_user!, only: [:new, :create, :confirm,
                     :password_reset_request, :password_update, :password_update_form]
  before_filter :owns_data!
  skip_before_action :owns_data!, only: [:new, :create, :confirm,
                     :password_reset_request, :password_update, :password_update_form]
  include SessionsHelper
  include ApplicationHelper

  def new
    unless current_user.nil?
      redirect_to :cameras_index
      return
    end
    @countries     = Country.all
    @share_request = nil
    if params[:key]
      @share_request = CameraShareRequest.where(status: CameraShareRequest::PENDING,
                                                key: params[:key]).first
    end
  end

  def create
    if params.has_key?('user')
      body = {
        :forename => params[:user]['forename'],
        :lastname => params[:user]['lastname'],
        :username => params[:user]['username'],
        :email => params[:user]['email'],
        :country => params['country'],
        :password => params[:user]['password']
      }
      body[:share_request_key] = params[:key] if params.include?(:key)

      response  = API_call("users", :post, body)
    end
    if response.nil? or not response.success?
      @share_request = nil
      if params[:key]
        @share_request = CameraShareRequest.where(status: CameraShareRequest::PENDING,
                                                  key: params[:key]).first
      end
      if !response.nil?
         Rails.logger.error "API request returned successfully. Response:\n#{response.body}"
         flash[:message] = JSON.parse(response.body)['message']
       end
      @countries = Country.all
      render :new
    else
      @user = User.where(email: params[:user]['email'].downcase).first
      sign_in @user
      redirect_to "/"
    end
  end

  def confirm
    user = User.where(Sequel.expr(email: params[:u]) | Sequel.expr(username: params[:u])).first
    unless user.nil?
      code = Digest::SHA1.hexdigest(user.username + user.created_at.to_s)
      if params[:c] == code
        user.confirmed_at = Time.now
        user.save
        flash[:notice] = 'Successfully activated your account'
      else
        flash[:notice] = 'Activation code is incorrect'
      end
    end
    redirect_to '/signin'
  end

  def settings
    @countries = Country.all
  end

  def settings_update
    body = {
      :forename => params['user-forename'],
      :lastname => params['user-lastname'],
      :country => params['country']
    }

    body[:email] = params['email'] unless params['email'] == current_user.email

    response  = API_call("users/#{current_user.username}", :patch, body)

    if response.success?
      flash.now[:message] = 'Settings updated successfully'
      session[:user] = User.by_login(current_user.username).email
    else
      flash.now[:message] = JSON.parse(response.body)['message']
    end
    @countries = Country.all
    refresh_user
    render :settings
  end

  def password_reset_request
    email = params[:email]
    unless email.nil?
      user = User.by_login(email)

      if user
        t = Time.now
        if user.reset_token.present? and user.token_expires_at.present? and user.token_expires_at > t
          expires = user.token_expires_at
          token = user.reset_token
        else
          expires = t + 24.hour
          token = SecureRandom.hex(16)
        end

        user.update(reset_token: token, token_expires_at: expires)

        UserMailer.password_reset(email, user, token).deliver
        flash[:message] = "We’ve sent you an email with instructions for changing your password."
      else
        flash[:message] = "Email address not found."
      end


    end
  end

  def password_update_form
    username = params[:u]
    user = User.by_login(username)
    if user.nil? or user.token_expires_at.blank? or user.token_expires_at < Time.now
      @expired = true
    else
      @expired = false
    end
    render "password_update"
  end

  def password_update
    token = params[:token]
    username = params[:username]
    user = User.by_login(username)
    if user.nil? or token != user.reset_token or user.token_expires_at < Time.now
      flash[:message] = 'Invalid username or token'
    else
      user.update(password: params[:password], reset_token: '', token_expires_at: Time.now)
      sign_in user
      redirect_to "/", message: 'Your password has been changed'
    end
  end

end
