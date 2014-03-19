require_relative '../../app/models/default/user'

module SessionsHelper
  def sign_in(user)
    cookies.permanent[:user] = user.email
    @current_user = user
  end

  def sign_out
    cookies.delete(:user)
    @current_user = nil
  end

  def signed_in?
    !@current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= Default::User.find_by(email: cookies[:user])
  end
end
