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
              :timelapse_annual
  def initialize
    @evercam_free = 0
    @evercam_free_annual = 0
    @evercam_pro = 999
    @evercam_pro_annual = 9900
    @evercam_pro_plus = 1499
    @evercam_pro_plus_annual = 19990
    @snapmail = 999
    @snapmail_annual = 9900
    @timelapse = 999
    @timelapse_annual = 9990
    @snapmail = 999
    @snapmail_annual = 9990
  end
end