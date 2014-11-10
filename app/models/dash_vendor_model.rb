class DashVendorModel < ActiveRecord::Base
  self.table_name = 'vendor_models'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'
  attr_accessible :name, :jpg_url

  belongs_to :vendor, :foreign_key => 'vendor_id', :class_name => 'DashVendor'
end
