class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :retrieve_stripe_subscriptions
  before_action :retrieve_add_ons

  include SessionsHelper
  include ApplicationHelper
  include StripeCustomersHelper
  require "stripe"

  def create
    stripe_customer = retrieve_stripe_customer
    stripe_customer.subscription.create(:plan => params[:plan_id])
    flash[:message] = "You have successfuly created a new #{params[:plan_name]} subscription."
    redirect_to user_path(current_user.username)
  end

  def destroy
    stripe_customer = retrieve_stripe_customer
    stripe_customer.subscriptions.retrieve(params[:subscription_id]).delete
    flash[:message] = "You have successfuly deleted your #{params[:plan_name]} subscription."
    redirect_to user_path(current_user.username)
  end

  private

  def retrieve_stripe_subscriptions
    if is_stripe_customer?
      @subscriptions = Stripe::Customer.retrieve(current_user.billing_id).subscriptions.all
    end
  end

  def retrieve_add_ons
    @user_add_ons = Billing.where(:user_id => current_user.id)
    return @user_add_ons.nil? ? false : @user_add_ons
  end
end
