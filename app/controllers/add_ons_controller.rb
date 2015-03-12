# Responsibilities:
# Retrieve add-ons from the billing table for current user
# Update the database with new quantities 
# Create a row in the billing table for a user if none exists and an add-on is being added

class AddOnsController < ApplicationController
  before_action :authenticate_user!
  include SessionsHelper
  include ApplicationHelper

  def index
    Rails.logger.info("Logging #{current_user.billing_id}")
    if user_add_ons?
      @snapmails = @user_add_ons.snapmail
      @timelapses = @user_add_ons.timelapse
    end
  end

  def create
    
  end

  private

  def user_add_ons?
    @user_add_ons = Billing.where(:user_id => current_user.id)
    return @user_add_ons.nil? ? false : @user_add_ons
  end
end 