class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  include SessionsHelper
  include ApplicationHelper
  include StripeCustomersHelper
  require "stripe"

  def new
  end

  def create
    plan_id = params[:plan_id]
    plan_name = params[:plan_name]
    stripe_customer = retrieve_stripe_customer
    stripe_customer.subscription.create(:plan => plan)
    flash[:message] = "You have successfuly created a new #{plan_name} subscription."
    redirect_to user_path(current_user.username)
  end

  def destroy
    stripe_customer = retrieve_stripe_customer
    stripe_customer.subscriptions.retrieve(params[:subscription_id]).delete
    flash[:message] = "You have successfuly deleted your #{params[:plan_name]} subscription."
    redirect_to user_path(current_user.username)
  end
end
