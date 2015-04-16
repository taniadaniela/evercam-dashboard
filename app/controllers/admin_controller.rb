class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorize_admin

  include SessionsHelper
  include ApplicationHelper

  layout 'admin'

  def authorize_admin
    redirect_to root_path unless current_user.is_admin?
  end
end
