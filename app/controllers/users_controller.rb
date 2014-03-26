class UsersController < ApplicationController
  include SessionsHelper
  include ApplicationHelper

  def new
    @countries = Default::Country.all
  end

  def create
    puts params
    body = {:forename => params[:user]['forename'],
            :lastname => params[:user]['lastname'],
            :username => params[:user]['username'],
            :email => params[:user]['email'],
            :country => params['country'],
            :password => params[:user]['password']
    }

    response  = API_call("/users", :post, body)

    puts response.body
    if response.success?
      @user = Default::User.find_by(email: params[:user]['email'].downcase)
      sign_in @user
      redirect_to "/"
    else
      flash[:message] = JSON.parse(response.body)['message']
      @countries = Default::Country.all
      render :new
    end
  end

  def settings
    @countries = Default::Country.all
  end

  def settings_update
    body = {:forename => params['user-forename'],
            :lastname => params['user-lastname'],
            :country => params['country']
    }

    body[:email] = params['email'] unless params['email'] == current_user.email

    response  = API_call("/users/#{current_user.username}", :patch, body)

    if response.success?
      redirect_to "/users/#{current_user.username}/settings"
    else
      puts response.body
      flash[:message] = JSON.parse(response.body)['message']
      @countries = Default::Country.all
      render :settings
    end
  end

end
