# This model should be removed as the prices should be availle as part of a hash of product data which comes from 
# either
# A single set of calls to Stripe from the application controller
# or a Product class file which contains the various data
# This is unsatisfactory, but details of add-ons will can't be easily stored on Stripe as they are not plans
class Prices
  attr_reader :evercam_free,
              :evercam_free_annual,
              :evercam_pro,
              :evercam_pro_annual,
              :evercam_pro_plus,
              :evercam_pro_plus_annual,
              :snapmail,
              :snapmail_annual,
              :timelapse,
              :timelapse_annual,
              :seven_days_recording,
              :seven_days_recording_annual,
              :thirty_days_recording,
              :thirty_days_recording_annual,
              :ninety_days_recording,
              :ninety_days_recording_annual,
              :restream,
              :restream_annual


  def initialize
    @evercam_free = 0
    @evercam_free_annual = 0
    @evercam_pro = 1000
    @evercam_pro_annual = 9600
    @evercam_pro_plus = 2000
    @evercam_pro_plus_annual = 19200
    @snapmail = 1000
    @snapmail_annual = 9600
    @timelapse = 1000
    @timelapse_annual = 9600
    @seven_days_recording = 1000
    @seven_days_recording_annual = 9600
    @thirty_days_recording = 2000
    @thirty_days_recording_annual = 19200
    @ninety_days_recording = 3000
    @ninety_days_recording_annual = 30000
    @restream = 1000
    @restream_annual = 9600
  end
end