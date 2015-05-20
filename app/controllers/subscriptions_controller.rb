class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :owns_data!
  layout "user-account"
  include CurrentCart
  before_filter :set_cart
  include SessionsHelper
  include ApplicationHelper
  include StripeCustomersHelper
  include StripeInvoicesHelper
  require "stripe"
  require "date"

  def index
    @cameras = load_user_cameras(true, false)
    set_prices
    @subscription = current_subscription
    @invoices = retrieve_customer_invoices
    retrieve_add_ons
    unless current_user.stripe_customer_id.blank?
      @credit_cards = retrieve_credit_cards
      @subscriptions = has_subscriptions? ? retrieve_stripe_subscriptions : nil
    end
  end

  def new
    @cameras = load_user_cameras(true, false)
    render layout: false
  end

  def create
    stripe_customer = retrieve_stripe_customer
    stripe_customer.subscription.create(:plan => params[:plan_id])
    flash[:message] = "You have successfuly created a new #{params[:plan_name]} subscription."
    redirect_to user_path(current_user.username)
  end

  def edit_subscription
    @cameras = load_user_cameras(true, false)
    set_prices
    @subscription = current_subscription
    @cart_count = cart_count
  end

  def edit_add_ons
    @cameras = load_user_cameras(true, false)
    @subscription = current_subscription
  end

  def destroy
    stripe_customer = retrieve_stripe_customer
    stripe_customer.subscriptions.retrieve(params[:subscription_id]).delete
    flash[:message] = "You have successfuly deleted your #{params[:plan_name]} subscription."
    redirect_to user_path(current_user.username)
  end

  def delete_add_ons
    begin
      if params[:add_ons_id].present?
        add_on = AddOn.find(id: params[:add_ons_id])
        flash[:message] = "You have successfuly deleted your '#{add_on.add_ons_name}' add-on."
        add_on.delete()
      else
        flash[:message] = "Invalid add-ons id specified."
      end
    rescue => error
      flash[:message] = "An error occurred while deleting add-ons. "\
                      "Please try again and, if the problem persists, contact "\
                      "support."
    end
    redirect_to billing_path(current_user.username)
  end
end
