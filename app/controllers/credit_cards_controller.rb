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
      flash[:message] = 'You card was successfully added.'
      redirect_to user_path(current_user.username)
    rescue Stripe::CardError => error
      flash[:error] = error.message
      redirect_to user_path(current_user.username)
    end
  end

  def destroy
    @customer ||= retrieve_stripe_customer
    begin
      @customer.sources.retrieve(params[:card_id]).delete
      flash[:message] = 'You card was successfully deleted.'
      redirect_to user_path(current_user.username)
    rescue
      rescue Stripe::CardError => error
      flash[:error] = error.message
    end
  end

  private

  def billing_id
    current_user.billing_id
  end
end

