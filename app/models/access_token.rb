class AccessToken < LegacyBase
  self.table_name = 'access_tokens'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'

  belongs_to :client, :foreign_key => 'client_id', :class_name => 'Client'
  belongs_to :user, :foreign_key => 'user_id', :class_name => 'User'
  has_many :camera_activities, :foreign_key => 'access_token_id', :class_name => 'CameraActivity'
  has_many :cameras, :through => :camera_activities, :foreign_key => 'camera_id', :class_name => 'Camera'
end
