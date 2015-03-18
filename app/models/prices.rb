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
    @evercam_pro_plus_annual = 14900
    @snapmail = 999
    @snapmail_annual = 14900
    @timelapse = 1999
    @timelapse_annual = 17900
  end
end