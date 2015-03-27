module ChargesHelper
  def add_ons_in_cart?
    session[:cart].detect {|i| i.type.eql?('add_on') } ? true : false
  rescue
    nil
  end
end
