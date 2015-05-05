class LineItemsController < ApplicationController
  include SessionsHelper
  include ApplicationHelper
  include CurrentCart
  before_action :set_cart
  
  def create_subscription
    @current_subscription = current_subscription
    product_params = build_line_item_params(params)
    @line_item = LineItem.new(product_params)
    purge_plan_from_cart
    if change_of_plan?
      save_to_cart
    else
      flash.now[:message] = "You are already on the #{@line_item.name} plan."
    end
  end

  def create_add_on
    @current_subscription = current_subscription
    product_params = build_line_item_params(params)
    @line_item = LineItem.new(product_params)
    if can_add_to_cart?
      save_to_cart
    else
      flash.now[:message] = "Can not add this item."
    end
  end

  def destroy
    session[:cart].delete_if {|item| item.id.eql?(params[:id]) }
  end

  private

  def build_line_item_params params
    selector = ProductSelector.new(params[:product_id])
    selector.product_params
  end

  def change_of_plan?
    if defined? @current_subscription.id
      !@current_subscription.id.eql?(@line_item.product_id)
    else
      true
    end
  end

  def save_to_cart
    session[:cart].push(@line_item)
      respond_to do |format|
        format.js
      end
  end

  def can_add_to_cart?
    (plan_in_cart? || existing_subscription?) ? true : false #&& valid_duration?
  end

  def existing_subscription?
    @current_subscription
  end

  def valid_duration?
    if plan_in_cart?
      plan_in_cart.interval.eql?(@line_item.interval)
    elsif @current_subscription.interval.eql?(@line_item.interval)
      true
    else
      false
    end
  end
end