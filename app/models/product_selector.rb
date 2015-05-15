# This is ugly:
# The data below could be retrieved from Stripe but there will also be information needed for add ons, which cannot be easily returned from Stripe
class ProductSelector
  attr_reader :evercam_free, :evercam_free_annual,
              :evercam_pro, :evercam_pro_annual,
              :evercam_pro_plus, :evercam_pro_plus_annual

  def initialize product_id
    @product_id = product_id
    @evercam_free = { product_id: 'evercam-free', type: 'plan', name: 'Evercam Free', price: 0, interval: 'month' }
    @evercam_free_annual = { product_id: 'evercam-free-annual', type: 'plan', name: 'Evercam Free Annual', price: 0, interval: 'year' }
    @evercam_pro = { product_id: 'evercam-pro', type: 'plan', name: 'Evercam Pro Monthly', price: 999, interval: 'month' }
    @evercam_pro_annual = { product_id: 'evercam-pro-annual', type: 'plan', name: 'Evercam Pro Annual', price: 14900, interval: 'year' }
    @evercam_pro_plus = { product_id: 'evercam-pro-plus', type: 'plan', name: 'Evercam Pro Plus Monthly', price: 1999, interval: 'month' }
    @evercam_pro_plus_annual = { product_id: 'evercam-pro-plus-annual', type: 'plan', name: 'Evercam Pro Plus Annual', price: 17900, interval: 'year' }
    @snapmail = { product_id: 'snapmail', type: 'add_on', name: 'Snapmail', price: 999, interval: 'month' }
    @snapmail_annual = { product_id: 'snapmail-annual', type: 'add_on', name: 'Snapmail', price: 14900, interval: 'year' }
  end

  # Used by the line_items_controller to have the necessary data to calculate a total, and display other data.
  def product_params
    case @product_id
      when "evercam-free"
        @evercam_free
      when "evercam-free-annual"
        @evercam_free_annual
      when "evercam-pro"
        @evercam_pro
      when "evercam-pro-annual"
        @evercam_pro_annual
      when "evercam-pro-plus"
        @evercam_pro_plus
      when "evercam-pro-plus-annual"
        @evercam_pro_plus_annual
      when "snapmail"
        @snapmail
      when "snapmail-annual"
        @snapmail_annual
    end
  end
end