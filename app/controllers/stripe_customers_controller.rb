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
    # logger.debug response
    stripe_customer_id = response.id

    unless current_user.billing_id
      current_user.billing_id = stripe_customer_id
      current_user.save
    end
    redirect_to :users
  end

  private

  def associate_stripe_and_evercam_emails
    
  end


end
