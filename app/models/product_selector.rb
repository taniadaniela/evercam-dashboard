# This is ugly:
# The data below could be retrieved from Stripe but there will also be information needed for add ons, which cannot be easily returned from Stripe
class ProductSelector
  attr_reader :seven_days_recording, :seven_days_recording_annual,
              :thirty_days_recording, :thirty_days_recording_annual,
              :ninety_days_recording, :ninety_days_recording_annual

  def initialize product_id
    product_prices = Prices.new
    @product_id = product_id

    @seven_days_recording = { product_id: '7-days-recording', type: 'plan', name: '7 Days Recording', price: product_prices.seven_days_recording, interval: 'month' }
    @seven_days_recording_annual = { product_id: '7-days-recording-annual', type: 'plan', name: '7 Days Recording Annual', price: product_prices.seven_days_recording_annual, interval: 'year' }

    @thirty_days_recording = { product_id: '30-days-recording', type: 'plan', name: '30 Days Recording', price: product_prices.thirty_days_recording, interval: 'month' }
    @thirty_days_recording_annual = { product_id: '30-days-recording-annual', type: 'plan', name: '30 Days Recording Annual', price: product_prices.thirty_days_recording_annual, interval: 'year' }

    @ninety_days_recording = { product_id: '90-days-recording', type: 'plan', name: '90 Days Recording', price: product_prices.ninety_days_recording, interval: 'month' }
    @ninety_days_recording_annual = { product_id: '90-days-recording-annual', type: 'plan', name: '90 Days Recording Annual', price: product_prices.ninety_days_recording_annual, interval: 'year' }
  end

  # Used by the line_items_controller to have the necessary data to calculate a total, and display other data.
  def product_params
    case @product_id
      when "7-days-recording"
        @seven_days_recording
      when "7-days-recording-annual"
        @seven_days_recording_annual
      when "30-days-recording"
        @thirty_days_recording
      when "30-days-recording-annual"
        @thirty_days_recording_annual
      when "90-days-recording"
        @ninety_days_recording
      when "90-days-recording-annual"
        @ninety_days_recording_annual
    end
  end
end