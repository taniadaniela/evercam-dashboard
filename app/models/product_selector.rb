# This is ugly:
# The data below could be retrieved from Stripe but there will also be information needed for add ons, which cannot be easily returned from Stripe
class ProductSelector
  attr_reader :evercam_free, :evercam_free_annual,
              :evercam_pro, :evercam_pro_annual,
              :evercam_pro_plus, :evercam_pro_plus_annual

  def initialize product_id
    @product_id = product_id
    @evercam_free = { product_id: 'evercam_free', type: 'plan', name: 'Evercam Free', price: 0, duration: 'monthly' }
    @evercam_free_annual = { product_id: 'evercam_free_annual', type: 'plan', name: 'Evercam Free Annual', price: 0, duration: 'annual' }
    @evercam_pro = { product_id: 'evercam_pro', type: 'plan', name: 'Evercam Pro', price: 999, duration: 'monthly' }
    @evercam_pro_annual = { product_id: 'evercam_pro_annual', type: 'plan', name: 'Evercam Pro Annual', price: 14900, duration: 'annual' }
    @evercam_pro_plus = { product_id: 'evercam_pro_plus', type: 'plan', name: 'Evercam Pro Plus', price: 1999, duration: 'monthly' }
    @evercam_pro_plus_annual = { product_id: 'evercam_pro_plus_annual', type: 'plan', name: 'Evercam Pro Plus Annual', price: 17900, duration: 'annual' }
  end

  # Used by the line_items_controller to have the necessary data to calculate a total, and display other data.
  def product_params
    case @product_id
    when "evercam_free"
      @evercam_free
    when "evercam_free_annual"
      @evercam_free_annual
    when "evercam_pro"
      @evercam_pro
    when "evercam_pro_annual"
      @evercam_pro_annual
    when "evercam_pro_plus"
      @evercam_pro_plus
    when "evercam_pro_plus_annual"
      @evercam_pro_plus_annual
    end
  end
end