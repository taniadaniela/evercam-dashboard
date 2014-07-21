class DashCameraShare < ActiveRecord::Base
  self.table_name = 'camera_shares'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'

  belongs_to :dash_camera, :foreign_key => 'camera_id', :class_name => 'DashCamera'
  belongs_to :dash_user, :foreign_key => 'user_id', :class_name => 'DashUser'
end
