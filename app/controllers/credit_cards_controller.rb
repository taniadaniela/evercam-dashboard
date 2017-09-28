class CreditCardsController < ApplicationController
  before_action :authenticate_user!
  layout "user-account"
  include SessionsHelper
  include ApplicationHelper
  include StripeCustomersHelper
  include SubscriptionsHelper
  require "stripe"

  def create
    customer = retrieve_stripe_customer
    card_fingerprint = Stripe::Token.retrieve(params[:stripeToken]).try(:card).try(:fingerprint)
    default_card = customer.cards.all.data.select { |card| card.fingerprint == card_fingerprint }.last if card_fingerprint
    card = customer.cards.create(card: params[:stripeToken]) unless default_card
    begin
      if card.present?
        customer.default_card = card.id
        flash[:message] = "Your card {#{card.last4}} was successfully added."
      else
        customer.default_card = default_card.id
        flash[:message] = "Your card {#{default_card.last4}} already exists."
      end
      customer.save
    rescue Stripe::CardError => error
      flash[:error] = error.message
    end
    redirect_to billing_path(current_user.username)
  end

  def destroy
    @customer ||= retrieve_stripe_customer
    begin
      last_Four = @customer.sources.retrieve(params[:card_id]).last4
      @customer.sources.retrieve(params[:card_id]).delete
      flash[:message] = "Your card {#{last_Four}} was successfully deleted."
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

