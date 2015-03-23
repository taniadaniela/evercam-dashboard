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
    if plan_changed?(@line_item.product_id)
      session[:cart].push(@line_item)
      respond_to do |format|
        format.js
      end
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

  def plan_changed? plan
    @current_plan[:id].eql?(plan) ? false : true
  end

  def purge_plan_from_cart
    session[:cart].delete_if {|item| item.type.eql?('plan') }
  end
end