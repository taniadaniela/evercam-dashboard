module Default
  class Vendor < DbBase
    self.table_name = 'vendors'
    self.inheritance_column = 'ruby_type'
    self.primary_key = 'id'

    if ActiveRecord::VERSION::STRING < '4.0.0' || defined?(ProtectedAttributes)
      attr_accessible :created_at, :updated_at, :exid, :known_macs, :name
    end

    has_many :firmwares, :foreign_key => 'vendor_id', :class_name => 'Firmware'
  end
end