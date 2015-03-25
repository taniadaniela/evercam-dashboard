class ChargeCalculator
  def add_ons_charge cart_items
      amounts = cart_items.map { |item| item.price }
      amounts.inject(0) {|sum, i|  sum + i }
  end

  def charge_description cart_items
    description = 'Description: '
    cart_items.each do |item|
        description.push(item.name + '\n')
      end
  end 
end