class CheckoutsController < ApplicationController
  include SessionsHelper
  include ApplicationHelper
  before_action :redirect_when_cart_empty


  def new

  end




  private

  def redirect_when_cart_empty
    if session[:cart].empty?
      redirect_to edit_subscriptions_path
    end
  end
end

