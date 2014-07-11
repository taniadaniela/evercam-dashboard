class DashCamera < ActiveRecord::Base
  self.table_name = 'cameras'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'

  attr_protected :admin

  # has_many :access_rights, :foreign_key => 'camera_id', :class_name => 'AccessRight'
  # has_many :camera_activities, :foreign_key => 'camera_id', :class_name => 'CameraActivity'
  # has_many :camera_endpoints, :foreign_key => 'camera_id', :class_name => 'CameraEndpoint'
  # has_many :camera_share_requests, :foreign_key => 'camera_id', :class_name => 'CameraShareRequest'
  # has_many :camera_shares, :foreign_key => 'camera_id', :class_name => 'CameraShare'
  # has_many :snapshots, :foreign_key => 'camera_id', :class_name => 'Snapshot'
  # has_many :snapshots_by_access_rights, :source => :snapshot, :through => :access_rights, :foreign_key => 'snapshot_id', :class_name => 'Snapshot'
  # has_many :access_tokens, :through => :camera_activities, :foreign_key => 'access_token_id', :class_name => 'AccessToken'
  # has_many :users_by_camera_share_requests, :source => :user, :through => :camera_share_requests, :foreign_key => 'user_id', :class_name => 'User'
  # has_many :users_by_camera_shares, :source => :user, :through => :camera_shares, :foreign_key => 'user_id', :class_name => 'User'
end
