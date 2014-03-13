module Default
  class SpatialRefSy < DbBase
    self.table_name = 'spatial_ref_sys'
    self.inheritance_column = 'ruby_type'
    
    if ActiveRecord::VERSION::STRING < '4.0.0' || defined?(ProtectedAttributes)
      attr_accessible :srid, :auth_name, :auth_srid, :srtext, :proj4text
    end

  end
end