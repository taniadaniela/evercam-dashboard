class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :owns_data!
  layout "user-account"
  include SessionsHelper
  include ApplicationHelper
  include StripeCustomersHelper
  include StripeInvoicesHelper
  # require "stripe"
  # require "date"

  def index
    if current_user.insight_id.present?
      @insight_url = "#{ENV['INSIGHT_URL']}AuthKey=#{ENV['invoice_auth_key']}&JSONObject&CustomerCode=#{current_user.insight_id}"
    end
    @cameras = load_user_cameras(true, false)
    set_prices
    @next_charge = retrieve_customer_next_charge
    @cameras_products = Camera.where(owner: current_user).eager(:cloud_recording).all
    @custom_licence = Licence.where(user_id: current_user.id).where(cancel_licence: false, subscription_id: nil)
    unless current_user.stripe_customer_id.blank?
      @credit_cards = retrieve_credit_cards
      @subscriptions = has_subscriptions? ? retrieve_stripe_subscriptions : nil
    end
    retrieve_plans_quantity(@subscriptions)
  end

  def billing_history
    if params[:invoice_id]
      description = retrieve_customer_plan(params[:invoice_id])
      render json: { description: description }
    elsif params[:invoices]
      invoices = retrieve_customer_invoices
      render json: invoices
    else
      billing_history = retrieve_customer_billing_history
      render json: billing_history
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

  def destroy
    subscription = Stripe::Subscription.retrieve(params[:subscription_id])
    subscription.delete(:at_period_end => true)
    render json: {result: true}
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

  def edit_subscription
    subscription = Stripe::Subscription.retrieve(params[:subscription_id])
    subscription.plan = params[:plan]
    subscription.quantity = params[:quantity].to_i
    subscription.save
    render json: {result: true}
  end

  def subscription_data
    subscription =  has_subscriptions? ? retrieve_stripe_subscriptions : nil
    render json: {subscription: subscription[:data]}
  end
end
