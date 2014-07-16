geocoded_by :address
after_validation :geocode, :if => :address_changed?