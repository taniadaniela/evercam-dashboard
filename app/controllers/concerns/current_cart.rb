module CurrentCart
  extend ActiveSupport::Concern

  private

    def set_cart
      session[:cart] ||= Array.new
    end

   def calculate_total
      amounts = session[:cart].map { |item| item.price }
      @total = amounts.inject(0) {|sum, i|  sum + i }
   end 
end