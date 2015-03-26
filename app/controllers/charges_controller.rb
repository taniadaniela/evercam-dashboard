class ChargesController < ApplicationController
  before_filter :ensure_plan_in_cart_or_existing_subscriber
  prepend_before_filter :ensure_card_exists
  include SessionsHelper
  include ApplicationHelper
  include CurrentCart

  def create
    @customer = StripeCustomer.new(current_user.billing_id, plan_in_cart)
    create_subscription unless @customer.has_active_subscription?
    change_plan if @customer.change_of_plan?
    create_charge if add_ons_in_cart?
    redirect_to subscriptions_path, flash: {message: "Success."}
  end

  private

  def ensure_card_exists
    @customer = StripeCustomer.new(current_user.billing_id)
    unless @customer.valid_card?
      redirect_to edit_subscription_path, flash: {message: "You must add a card."}
    end
  end

  def ensure_plan_in_cart_or_existing_subscriber
    unless @customer.has_active_subscription? || plan_in_cart?
      redirect_to edit_subscription_path, flash: {message: "You must add a plan."}
    end
  end

  def create_subscription
    @customer.create_subscription
    purge_plan_from_cart
    flash[:message] = "Plan created."
  rescue
    flash[:error] = "Something went wrong."
  end

  def change_plan
    @customer.change_plan 
    purge_plan_from_cart
    flash[:message] = "Plan Changed."
  rescue
    flash[:error] = "Something went wrong."
  end

  def create_charge
    @customer.create_charge(add_ons_charge, charge_description)
    empty_cart
  rescue
    flash[:error] = "Something went wrong."
  end

  def add_ons_charge
    amounts = add_ons_in_cart.map { |item| item.price }
    amounts.inject(0) {|sum, i|  sum + i }
  end

  def charge_description
    description = ''
    add_ons_in_cart.each_with_index do |item, index|
        description.concat(item.name)
        unless index.eql?(add_ons_in_cart.length - 1)
          description.concat(', ')
        else
          description.concat('.')
        end
      end
    description
  end 
end

