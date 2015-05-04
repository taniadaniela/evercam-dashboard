class AddOns < ActiveRecord::Base
  attr_protected :charges
  self.table_name = 'add_ons'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'


  #Add-ons Name
  @@snapmail = 'snapmail'
  @@timelapse = 'timelapse'

  def self.snapmail
    @@snapmail
  end

  def self.timelapse
    @@timelapse
  end

  # Prices of Add-ons
  @@snapmail_price = 1000
  @@timelapse_price = 3000

  def self.snapmail_price
    @@snapmail_price
  end

  def self.timelapse_price
    @@timelapse_price
  end
end