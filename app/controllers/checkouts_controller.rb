class CheckoutsController < ApplicationController
  include SessionsHelper
  include ApplicationHelper
  include CurrentCart
  before_action :redirect_when_cart_empty
  before_action :calculate_total

  def new
    @total
  end




  private

  def redirect_when_cart_empty
    if session[:cart].empty?
      redirect_to edit_subscription_path
    end
  end
end

