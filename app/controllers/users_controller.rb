class UsersController < ApplicationController
  before_filter :authenticate_user!
  skip_before_action :authenticate_user!, only: [:new, :create, :confirm]
  before_filter :owns_data!
  skip_before_action :owns_data!, only: [:new, :create, :confirm]
  include SessionsHelper
  include ApplicationHelper

  def new
    unless current_user.nil?
      redirect_to :cameras_index
      return
    end
    @countries = Country.all
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

      response  = API_call("users", :post, body)
    end
    if response.nil? or not response.success?
      flash[:message] = JSON.parse(response.body)['message'] unless response.nil?
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
      flash[:message] = 'Settings updated successfully'
    else
      flash[:message] = JSON.parse(response.body)['message']
    end
    @countries = Country.all
    render :settings
  end

end
