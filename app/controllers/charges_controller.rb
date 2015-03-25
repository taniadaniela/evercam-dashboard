class ChargesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_plan_in_cart_or_existing_subscriber
  prepend_before_filter :ensure_card_exists
  include SessionsHelper
  include ApplicationHelper

  # Billing ID  should be set and saved to the DB when a card is added.
  # Charges controller should redirect if no card is on file
  # Checkout and and add-ons view should redirect to plan select if no plan in cart and not a subscriber,
  # so a user should never call 
  def new
      stripe_customer = StripeCustomer.new current_user.billing_id
      calc = ChargeCalculator.new
      if !stripe_customer.has_active_subscription? && !stripe_customer.change_of_plan?
        amount = calc.add_ons_charge(add_ons_in_cart)
        desciption = calc.charge_description(add_ons_in_cart)
        logger.info("Logging amount #{amount} and #{description}")
        stripe_customer.create_charge(amount, description)
      end
  end

  def create
    customer = StripeCustomer.new current_user.billing_id
    customer.create_subscription() unless customer.has_active_subscription?
    description = generate_description
    charge = Stripe::Charge.create(
        :customer    => current_user.billing_id,
        :amount => params[:amount],
        :description => description,
        :currency    => 'eur'
      )
    flash[:message] = 'Your Payment was successful'
  rescue Stripe::CardError => e
    flash[:error] = e.message
  end

  def subscription_create
    @cameras = load_user_cameras(true, false)
    @email = current_user.email
    @plan = params[:plan]
    token = params[:token]
    if token.blank?
      customer = Stripe::Customer.create(
        :email => @email,
        :card  => params[:stripeToken],
        :plan => @plan
      )
      current_user.billing_id = customer.id
      current_user.save
    else
      customer = Stripe::Customer.retrieve(token)
      customer.subscriptions.create(
       :plan => @plan
      )
    end
    redirect_to(:back)
    flash[:message] = "Your Subscription was successful"
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to(:back)
  end

  def subscription_update
    token = params[:token]
    subscription_id = params[:subscription_id]
    customer = Stripe::Customer.retrieve(token)
    customer.subscriptions.retrieve(subscription_id).delete
    current_user.billing_id = customer.id
    current_user.save
    redirect_to(:back)
    flash[:message] = "Your Subscription has been cancelled"
  end

  private

  def ensure_card_exists

  end

  def ensure_plan_in_cart_or_existing_subscriber
    stripe_customer = StripeCustomer.new current_user.billing_id
    unless !stripe_customer.has_active_subscription? || plan_in_cart?
      redirect_to edit_subscription_path
    end
  end

  def add_ons_in_cart
    cart = session[:cart]
    cart.delete_if {|item| item.type.eql?('plan') }
    cart
  end

end

