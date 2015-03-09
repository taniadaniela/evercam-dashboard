class InvoicesController < ApplicationController

  def update
    
  end

  private

  # check for and return the number of addon

  def add_ons_cost
    AddOn.snapchat_price * @snapchats + AddOn.timelapse.price

  def user_add_ons
    @number_of_snapchats = user_bill.snapchats ? user_bill.snapchats : 0
    @number_of_timelapses = user_bill.snapchats ? user_bill.snapchats : 0

  end

  def user_bill
    Billing.where(:user_id => current_user.id)
  end
end