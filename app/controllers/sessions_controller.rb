require_relative '../../app/models/default/user'

class SessionsController < ApplicationController
  include SessionsHelper

  def index
  end

  def create
    begin
      @user = Default::User.find_by(email: params[:session][:email].downcase) || Default::User.find_by(username: params[:session][:email].downcase)
    rescue NoMethodError => _
    end

    if !@user.nil? and @user.password_bcrypt == params[:session][:password]
      sign_in @user
      redirect_to :cameras_index
    else
      flash[:error] = 'Invalid email/password combination' # Not quite right!
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to '/signin'
  end
end
