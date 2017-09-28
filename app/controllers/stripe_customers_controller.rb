class StripeCustomersController < ApplicationController
  before_action :authenticate_user!
  include SessionsHelper
  include ApplicationHelper
  include StripeCustomersHelper
  require "stripe"

  def create
    token = params[:stripeToken]
    email = current_user.email
    response = Stripe::Customer.create(
        email: email,
        source: token
      )
    stripe_customer_id = response.id
    unless current_user.stripe_customer_id
      current_user.stripe_customer_id = stripe_customer_id
      current_user.save
    end
    flash[:message] = "Card Successfully Added"
    redirect_to billing_path(current_user.username)
  end

  def update
    customer = retrieve_stripe_customer
    if(params.has_key?(:default_source))
      customer.default_source = params[:card_id]
    end
    customer.save
    redirect_to billing_path(current_user.username)
  end

  def destroy
    customer = retrieve_stripe_customer
    default_card = customer.default_source
    customer.sources.retrieve(default_card).delete
    customer.retrieve_stripe_customer
    redirect_to billing_path(current_user.username)
  end
end
