class LineItemsController < ApplicationController
  include SessionsHelper
  include ApplicationHelper
  include CurrentCart
  before_action :set_cart

  def index
    @line_items = session[:cart]
  end  

  def create
    product_params = build_line_item_params(params)
    @line_item = LineItem.new(product_params)
    logger.info("Logging line item #{@line_item.type}")

    # if @line_item.type.eql?('plan')
    #   remove_existing_plan
    # end
    session[:cart].push(@line_item)
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

  def remove_existing_plan
    sessions[:cart].find do |item|
      item.type == 'plan'
    end
  end

  def purge_cart
    session.delete(:cart)
  end
end