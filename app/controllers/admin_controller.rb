class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorize_admin
  skip_after_filter :intercom_rails_auto_include

  include SessionsHelper
  include ApplicationHelper

  layout 'admin'

  def authorize_admin
    redirect_to root_path unless current_user.is_admin?
  end
end
