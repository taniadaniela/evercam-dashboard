class LineItemsController < ApplicationController
  before_action :ensure_cart_exists
  # Line items will be objects, with object_ids
  # We will store the id in a hash in the sessions array
  def index
    @line_items = session[:cart]
  end  

  def create
    @line_item = LineItem.new(params[:plan_id],
                               params[:plan_name],
                               params[:price],
                               params[:duration],
                               params[:quantity])
    @line_item.id = @line_item.object_id
    session[:cart].push(@line_item)
    redirect_to user_path(current_user.username)
  end

  def destroy
    session[:cart].delete(params[:line_item_id])
    purge_cart
  end

  private

  def ensure_cart_exists
    session.push(Array(:cart) unless session.include?(:cart)
  end

  def purge_cart
    session.delete(:cart)
  end
end