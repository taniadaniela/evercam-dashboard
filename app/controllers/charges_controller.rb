class ChargesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_card_exists
  include SessionsHelper
  include ApplicationHelper

  # Billing ID  should be set and saved to the DB when a card is added.
  # Charges controller should redirect if no card is on file
  # Use remote: :true on posts to this controller
  def create
    logger.info("Logging billing id #{current_user.billing_id}")
    customer = StripeCustomer.new current_user.billing_id
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
    # customer = StripeCustomer.new current_user.billing_id
    # unless customer.valid_card?
    #   flash[:message] = 'Please add a valid credit card'
    #   redirect_to edit_subscriptions_path
    # end
  end

  def generate_description
    # Concatenate names of items, passed to the controller
    # dummy string for now
    'Charge Description'
  end
end

