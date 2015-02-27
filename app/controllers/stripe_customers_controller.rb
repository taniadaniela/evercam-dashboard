class StripeCustomersController < ApplicationController
  before_filter :authenticate_user!
  include SessionsHelper
  include ApplicationHelper
  require "stripe"

  # No new action, as form is created by Stripe.js, which returns the token used by stripe_customers#create

  # Create Customer via Stripe
  def create
    token = params[:stripeToken]
    email = current_user.email
    response = Stripe::Customer.create(
        email: email,
        source: token
      )
    stripe_customer_id = response.id
    unless current_user.billing_id
      current_user.billing_id = stripe_customer_id
      current_user.save
    end
    flash[:message] = "Card Successfully Added"
    redirect_to :user
  end

  # Update Card
  def update
    render layout: false
    token = params[:stripeToken]
    Rails.logger.warn "What is going on"
    # email = current_user.email
    # cu = retrieve_stripe_customer
    # cu.card = token
    # cu.save
    redirect_to '/'
  end

  # Delete customer on Stripe
  def destroy
    cu = Stripe::Customer.retrieve(current_user.billing_id)
    logger.debug cu
    # response = cu.default_source.delete
    # Rails.logger response
    redirect_to '/'
  end

  private

  def retrieve_stripe_customer
    stripe_customer_id = current_user.billing_id
    Stripe::Customer.retrieve(stripe_customer_id)
  end
end
