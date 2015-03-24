# Creates the line_items from the product_id passed from the views
# Have before actions to set cart and plan here nfor now, I assumed I could set these once in the application controller but they were not always being loaded
class LineItemsController < ApplicationController
  include SessionsHelper
  include ApplicationHelper
  include CurrentCart
  before_action :set_cart, :ensure_plan_set
  before_action :purge_plan_from_cart, only: [:create]

  def index
    @line_items = session[:cart]
  end  

  def show
  end
  
  def create
    product_params = build_line_item_params(params)
    @line_item = LineItem.new(product_params)
    if @line_item.type.eql?('plan')
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
    end
  end

  def create_add_on_line_item
    if valid_add_on_duration?
      session[:cart].push(@line_item)
      respond_to do |format|
        format.js
      end
    end
  end

  def valid_add_on_duration?
    if annual_plan_in_cart? && @line_item.duration.eql?('monthly')
      flash[:error] = "Monthly add-ons cannot be added to an annual plan."
      false
    elsif current_annual_subscription? && @line_item.duration.eql?('monthly')
      flash[:error] = "Monthly add-ons cannot be added to an annual plan."
      false
    elsif monthly_plan_in_cart? && @line_item.duration.eql?('annual')
      flash[:error] = "Annual add-ons cannot be added to an monthly plan."
      false
    elsif current_monthly_subscription? && @line_item.duration.eql?('annual')
      flash[:error] = "Annual add-ons cannot be added to an monthly plan."
      false
    else
      true
  end

  def plan_changed? plan
    @current_plan[:id].eql?(plan) ? false : true
  end

  def purge_plan_from_cart
    session[:cart].delete_if {|item| item.type.eql?('plan') }
  end

  def annual_plan_in_cart?
    line_item_duration.eql?('annual') ? true : false
  end

  def monthly_plan_in_cart?
    line_item_duration.eql?('monthly') ? true : false
  end

  def line_item_duration
    if session[:cart].empty?
      @current_plan.duration
    elsif plan = session[:cart].find(:type => 'plan').first
      plan.duration
    else
      @current_plan.duration
    end
  end

  # New sign up user defaults to evercam-free (monthly)
  def current_annual_subscription?
    @current_plan.duration.eql? 'annual'
  end

  def current_monthly_subscription
    
  end
end