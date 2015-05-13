class CreditCardsController < ApplicationController
  before_filter :authenticate_user!
  include SessionsHelper
  include ApplicationHelper
  include StripeCustomersHelper
  include SubscriptionsHelper
  require "stripe"

  def create
    customer = retrieve_stripe_customer
    card = customer.cards.create(:card => params[:stripeToken])
    begin
      customer.default_card = card.id
      customer.save
      flash[:message] = 'Your card was successfully added.'
      redirect_to billing_path(current_user.username)
    rescue Stripe::CardError => error
      flash[:error] = error.message
      redirect_to billing_path(current_user.username)
    end
  end

  def destroy
    @customer ||= retrieve_stripe_customer
    begin
      @customer.sources.retrieve(params[:card_id]).delete
      flash[:message] = 'Your card was successfully deleted.'
      redirect_to billing_path(current_user.username)
    rescue
      rescue Stripe::CardError => error
      flash[:error] = error.message
    end
  end

  private

  def billing_id
    current_user.stripe_customer_id
  end
end

