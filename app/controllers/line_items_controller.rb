# Creates the line_items from the product_id passed from the views
# Have before actions to set cart and plan here nfor now, I assumed I could set these once in the application controller but they were not always being loaded
class LineItemsController < ApplicationController
  include SessionsHelper
  include ApplicationHelper
  include CurrentCart
  before_action :set_cart, :set_user_plan

  def index
    @line_items = session[:cart]
  end  
  
  def create
    product_params = build_line_item_params(params)
    @line_item = LineItem.new(product_params)
    if @line_item.type.eql?('plan')
      purge_plan_from_cart
      create_plan_line_item
    elsif @line_item.type.eql?('add_on')
      create_add_on_line_item
    else
      raise('Could not select')
    end
  end

  def destroy
    session[:cart].delete_if {|item| item.id.eql?(params[:id]) }
  end

  private

  def build_line_item_params params
    p = ProductSelector.new(params[:product_id])
    p.product_params
  end

  def create_plan_line_item
    if plan_changed?(@line_item.product_id)
      session[:cart].push(@line_item)
      respond_to do |format|
        format.js
      end
    else flash.now[:message] = "You are already on the #{@line_item.name} plan."
    end
  end

  def create_add_on_line_item
    if can_add_add_on_to_cart?
      session[:cart].push(@line_item)
      respond_to do |format|
        format.js
      end
    end
  end

  def valid_add_on_duration?
    if annual_plan_in_cart? && @line_item.interval.eql?('month')
      flash.now[:message] = "Monthly add-ons cannot be added to an annual plan."
      false
    elsif current_annual_subscription? && @line_item.interval.eql?('month')
      flash.now[:message] = "Monthly add-ons cannot be added to an annual plan."
      false
    elsif monthly_plan_in_cart? && @line_item.interval.eql?('year')
      flash.now[:message] = "Annual add-ons cannot be added to an monthly plan."
      false
    elsif current_monthly_subscription? && @line_item.interval.eql?('year')
      flash.now[:message] = "Annual add-ons cannot be added to an monthly plan."
      false
    else
      true
    end
  end

  def existing_subscription?
    true
  end

  def can_add_add_on_to_cart?
    (valid_add_on_duration? && (plan_in_cart? || existing_subscription?)) ? true : false
  end

  def plan_changed? plan
    @current_plan[:id].eql?(plan) ? false : true
  end

  def purge_plan_from_cart
    session[:cart].delete_if {|item| item.type.eql?('plan') }
  end

  def annual_plan_in_cart?
    line_item_duration.eql?('year') ? true : false
  end

  def monthly_plan_in_cart?
    line_item_duration.eql?('month') ? true : false
  end

  def line_item_duration
    if session[:cart].empty?
      @current_plan.interval
    elsif plan = session[:cart].find(:type => 'plan').first
      plan.interval
    else
      @current_plan.interval
    end
  end

  # New sign up user defaults to evercam-free (monthly)
  def current_annual_subscription?
    @current_plan.interval.eql? 'year'
  end

  def current_monthly_subscription?
    @current_plan.interval.eql? 'month'
  end
end