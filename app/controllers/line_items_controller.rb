class LineItemsController < ApplicationController
  include SessionsHelper
  include ApplicationHelper
  include CurrentCart
  before_action :set_cart
  # before_action :purge_plan_from_cart, only: [:create]

  def index
    @line_items = session[:cart]
  end  

  def create
    purge_plan_from_cart
    logger.info("Logging cart #{session[:cart]}")
    product_params = build_line_item_params(params)
    @line_item = LineItem.new(product_params)
    if plan_change?(@line_item.product_id)
      session[:cart].push(@line_item)
    end
    redirect_to :back
  end

  def destroy
    session[:cart].delete(params[:line_item_id])
    purge_cart
  end

  private

  def build_line_item_params params
    p = ProductSelector.new(params[:product_id])
    p.product_params
  end

  def plan_change? plan
    if @current_plan.plan.id.eql?(plan)
      return false
    else
      return true
    end
  end

  def purge_plan_from_cart
    session[:cart].delete_if {|item| item.type.eql?('plan') }
  end

  def purge_cart
    session.delete(:cart)
  end
end