class AddOn < Sequel::Model
  many_to_one :owner, class: 'User', key: :user_id
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
