# This is ugly:
# The data below could be retrieved from Stripe but there will also be information needed for add ons, which cannot be easily returned from Stripe
class ProductSelector
  attr_reader :twenty_four_hours_recording, :twenty_four_hours_recording_annual,
              :infinity, :infinity_annual,
              :seven_days_recording, :seven_days_recording_annual,
              :thirty_days_recording, :thirty_days_recording_annual,
              :ninety_days_recording, :ninety_days_recording_annual

  def initialize product_id
    product_prices = Prices.new
    @product_id = product_id

    @twenty_four_hours_recording = { product_id: '24-hours-recording', type: 'plan', name: '24 Hours Recording', price: product_prices.twenty_four_hours_recording, interval: 'month' }
    @twenty_four_hours_recording_annual = { product_id: '24-hours-recording-annual', type: 'plan', name: '24 Hours Recording Annual', price: product_prices.twenty_four_hours_recording_annual, interval: 'year' }

    @infinity = { product_id: 'infinity', type: 'plan', name: 'Infinity', price: product_prices.infinity, interval: 'month' }
    @infinity_annual = { product_id: 'infinity-annual', type: 'plan', name: 'Infinity Annual', price: product_prices.infinity_annual, interval: 'year' }

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
    when "24-hours-recording"
      @twenty_four_hours_recording
    when "24-hours-recording-annual"
      @twenty_four_hours_recording_annual
    when "infinity"
      @infinity
    when "infinity-annual"
      @infinity_annual
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