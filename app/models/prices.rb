# This model should be removed as the prices should be availle as part of a hash of product data which comes from 
# either
# A single set of calls to Stripe from the application controller
# or a Product class file which contains the various data
# This is unsatisfactory, but details of add-ons will can't be easily stored on Stripe as they are not plans
class Prices
  attr_reader :twenty_four_hours_recording,
              :twenty_four_hours_recording_annual,
              :infinity,
              :infinity_annual,
              :seven_days_recording,
              :seven_days_recording_annual,
              :thirty_days_recording,
              :thirty_days_recording_annual,
              :ninety_days_recording,
              :ninety_days_recording_annual


  def initialize
    @twenty_four_hours_recording = 0
    @twenty_four_hours_recording_annual = 0
    @infinity = 5000
    @infinity_annual = 50000
    @seven_days_recording = 1000
    @seven_days_recording_annual = 10000
    @thirty_days_recording = 2000
    @thirty_days_recording_annual = 20000
    @ninety_days_recording = 3000
    @ninety_days_recording_annual = 30000
  end
end