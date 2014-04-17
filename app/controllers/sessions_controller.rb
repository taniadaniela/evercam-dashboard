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
    rescue NoMethodError => error
      Rails.logger.error "Error caught fetching user details.\nCause: #{error}\n" + error.backtrace.join("\n")
    end

    if !@user.nil? and @user.password == params[:session][:password]
      sign_in @user
      Rails.logger.debug "Redirecting to the cameras index action."
      redirect_to :cameras_index
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
