class CameraEndpoint < LegacyBase
  self.table_name = 'camera_endpoints'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'

  belongs_to :camera, :foreign_key => 'camera_id', :class_name => 'Camera'
end
