class SessionsController < ApplicationController
  include SessionsHelper

  def new
    unless current_user.nil?
      redirect_to :cameras_index
    end
  end

  def create
    begin
      address = params[:session][:email].downcase
      @user   = User.where(Sequel.expr(email: address) | Sequel.expr(username: address)).first
    rescue NoMethodError => _
    end

    if !@user.nil? and @user.password == params[:session][:password]
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
