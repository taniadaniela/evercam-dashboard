class UsersController < ApplicationController
  before_filter :authenticate_user!
  skip_before_action :authenticate_user!, only: [:new, :create]
  before_filter :owns_data!
  skip_before_action :owns_data!, only: [:new, :create]
  include SessionsHelper
  include ApplicationHelper

  def new
    @countries = Default::Country.all
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
      @countries = Default::Country.all
      render :new
    else
      @user = Default::User.find_by(email: params[:user]['email'].downcase)
      sign_in @user
      redirect_to "/"
    end
  end

  def settings
    @countries = Default::Country.all
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
    @countries = Default::Country.all
    render :settings
  end

end
