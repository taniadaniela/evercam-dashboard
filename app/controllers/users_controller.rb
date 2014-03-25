class UsersController < ApplicationController
  include SessionsHelper
  include ApplicationHelper

  def new

  end

  def settings
    @countries = Default::Country.all
  end

  def settings_update
    puts params
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
