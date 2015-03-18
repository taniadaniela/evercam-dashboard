module CurrentCart
  extend ActiveSupport::Concern

  private

    def set_cart
      session[:cart] ||= Array.new
    end
end