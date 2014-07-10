class Vendor < LegacyBase
  self.table_name = 'vendors'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'

  has_many :vendor_models, :foreign_key => 'vendor_id', :class_name => 'VendorModel'
end
