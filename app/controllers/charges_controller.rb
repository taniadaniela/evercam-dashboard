class ChargesController < ApplicationController
  before_filter :authenticate_user!
  include SessionsHelper
  include ApplicationHelper

  def new
    @cameras = load_user_cameras(true, true)
  end

  def create
    @cameras = load_user_cameras(true, true)

    @email = current_user.email
    @amount = params[:amount]

    token = params[:token]

    if token.blank?

      customer = Stripe::Customer.create(
        :email => @email,
        :card  => params[:stripeToken]
      )

      current_user.billing_id = customer.id
      current_user.save

    else

      customer = Stripe::Customer.retrieve(token)

    end

    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => @amount,
      :description => 'Evercam Dashboard Stripe customer',
      :currency    => 'eur'
    )

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to charges_path
  end

end

