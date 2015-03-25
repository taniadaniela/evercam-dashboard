class ChargesController < ApplicationController
  before_filter :ensure_plan_in_cart_or_existing_subscriber
  prepend_before_filter :ensure_card_exists
  include SessionsHelper
  include ApplicationHelper
  include CurrentCart

  # Billing ID  should be set and saved to the DB when a card is added.
  # Charges controller should redirect if no card is on file
  # Checkout and and add-ons view should redirect to plan select if no plan in cart and not a subscriber,
  # so a user should never call 
  def new
    customer = StripeCustomer.new(current_user.billing_id, plan_in_cart)
    customer.create_subscription unless customer.has_active_subscription?
    customer.change_plan if customer.change_of_plan?
    customer.create_charge(add_ons_charge, charge_description) if add_ons_in_cart?
  end

  def create
    customer = StripeCustomer.new(current_user.billing_id, plan_in_cart)
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
    customer = StripeCustomer.new(current_user.billing_id, plan_in_cart)
    unless customer.has_active_subscription? || plan_in_cart?
      redirect_to edit_subscription_path
    end
  end

  def add_ons_charge
      amounts = add_ons_in_cart.map { |item| item.price }
      amounts.inject(0) {|sum, i|  sum + i }
  end

  def charge_description
    description = 'Description: '
    add_ons_in_cart.each do |item|
        description.push(item.name + '\n')
      end
    description
  end 
end

