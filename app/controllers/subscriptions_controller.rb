class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :owns_data!
  layout "user-account"
  include SessionsHelper
  include ApplicationHelper
  include StripeCustomersHelper
  include StripeInvoicesHelper
  require "stripe"
  require "date"

  def index
    set_prices
    @subscription = current_subscription
    @billing_history = retrieve_customer_billing_history
    @invoices = retrieve_customer_invoices
    @next_charge = retrieve_customer_next_charge
    @cameras_products = Camera.where(owner: current_user).eager(:cloud_recording).all
    unless current_user.stripe_customer_id.blank?
      @credit_cards = retrieve_credit_cards
      @card = @credit_cards[:data][0] if @credit_cards.present?
      @subscriptions = has_subscriptions? ? retrieve_stripe_subscriptions : nil
    end
    retrieve_plans_quantity(@subscriptions)
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
        delete_invoice_item(add_on.invoice_item_id, add_on.price.to_i, add_on.add_ons_name)
        flash[:message] = "You have successfuly deleted your '#{add_on.add_ons_name}' add-on."
        add_on.delete()
      else
        flash[:message] = "Invalid add-ons id specified."
      end
    rescue => _error
      flash[:message] = "An error occurred while deleting add-ons. "\
                      "Please try again and, if the problem persists, contact "\
                      "support."
    end
    redirect_to billing_path(current_user.username)
  end
end
