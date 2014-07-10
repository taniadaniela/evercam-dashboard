class CameraActivity < LegacyBase
  self.table_name = 'camera_activities'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'

  belongs_to :access_token, :foreign_key => 'access_token_id', :class_name => 'AccessToken'
  belongs_to :camera, :foreign_key => 'camera_id', :class_name => 'Camera'
end
