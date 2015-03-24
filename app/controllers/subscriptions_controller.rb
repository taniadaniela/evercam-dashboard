class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_prices, :ensure_plan_set
  before_filter :ensure_cameras_loaded
  before_filter :retrieve_stripe_subscriptions
  before_filter :retrieve_add_ons
  include CurrentCart
  before_filter :set_cart
  include SessionsHelper
  include ApplicationHelper
  include StripeCustomersHelper
  require "stripe"

  def index

  end

  def new
    # @selected_plan = params
    render layout: false
  end

  def create
    stripe_customer = retrieve_stripe_customer
    stripe_customer.subscription.create(:plan => params[:plan_id])
    flash[:message] = "You have successfuly created a new #{params[:plan_name]} subscription."
    redirect_to user_path(current_user.username)
  end

  def edit_subscription

  end

  def edit_add_ons

  end

  def destroy
    stripe_customer = retrieve_stripe_customer
    stripe_customer.subscriptions.retrieve(params[:subscription_id]).delete
    flash[:message] = "You have successfuly deleted your #{params[:plan_name]} subscription."
    redirect_to user_path(current_user.username)
  end
end
