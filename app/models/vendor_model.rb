class VendorModel < LegacyBase
  self.table_name = 'vendor_models'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'

  belongs_to :vendor, :foreign_key => 'vendor_id', :class_name => 'Vendor'
end
