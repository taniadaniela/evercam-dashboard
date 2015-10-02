class AppsController < ApplicationController
  before_filter :authenticate_user!
  include SessionsHelper
  include ApplicationHelper
  layout "user-account"

  def index
    @tokens = AccessToken.where(user: current_user).or(grantor: current_user).and("expires_at > '#{Time.now}'").all
  end

  def revoke
    redirect_to apps_path(current_user.username)
  end
end