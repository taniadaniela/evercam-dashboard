class CameraShareRequest < LegacyBase
  self.table_name = 'camera_share_requests'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'

  belongs_to :camera, :foreign_key => 'camera_id', :class_name => 'Camera'
  belongs_to :user, :foreign_key => 'user_id', :class_name => 'User'
end
