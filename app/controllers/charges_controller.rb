class ChargesController < ApplicationController
  before_filter :authenticate_user!
  include SessionsHelper
  include ApplicationHelper


  def create

    @email = current_user.email
    @amount = params[:amount]
    token = params[:token]

    if token.blank?

      customer = Stripe::Customer.create(
      :email => @email,
      :card  => params[:stripeToken],
    )
      charge = Stripe::Charge.create(
        :customer    => customer.id,
        :amount => @amount,
        :description => 'Custom Amount from Billing',
        :currency    => 'eur'
      )

      current_user.billing_id = customer.id
      current_user.save

    else

      customer = Stripe::Customer.retrieve(token)
      customer.charges.create(
        :customer    => customer.id,
        :amount => @amount,
        :currency    => 'eur'
      )

    end

    redirect_to(:back)
    flash[:message] = "Your Payment was successful"

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to charges_path
  end

  def subscription_create

    @cameras = load_user_cameras(true, true)

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
    redirect_to charges_path
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



end

