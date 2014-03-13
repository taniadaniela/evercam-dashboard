module Default
  class CameraEndpoint < DbBase
    self.table_name = 'camera_endpoints'
    self.inheritance_column = 'ruby_type'
    self.primary_key = 'id'

    if ActiveRecord::VERSION::STRING < '4.0.0' || defined?(ProtectedAttributes)
      attr_accessible :camera_id, :scheme, :host, :port
    end

    belongs_to :camera, :foreign_key => 'camera_id', :class_name => 'Camera'
  end
end