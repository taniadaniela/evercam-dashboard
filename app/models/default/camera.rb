module Default
  class Camera < DbBase
    self.table_name = 'cameras'
    self.inheritance_column = 'ruby_type'
    self.primary_key = 'id'

    if ActiveRecord::VERSION::STRING < '4.0.0' || defined?(ProtectedAttributes)
      attr_accessible :created_at, :updated_at, :exid, :firmware_id, :owner_id, :is_public, :config, :name, :last_polled_at, :is_online, :timezone, :last_online_at, :location, :mac_address
    end

    belongs_to :firmware, :foreign_key => 'firmware_id', :class_name => 'Firmware'
    has_many :access_rights, :foreign_key => 'camera_id', :class_name => 'AccessRight'
    has_many :camera_activities, :foreign_key => 'camera_id', :class_name => 'CameraActivity'
    has_many :camera_endpoints, :foreign_key => 'camera_id', :class_name => 'CameraEndpoint'
    has_many :camera_shares, :foreign_key => 'camera_id', :class_name => 'CameraShare'
    has_many :snapshots, :foreign_key => 'camera_id', :class_name => 'Snapshot'
    has_many :access_tokens, :through => :camera_activities, :foreign_key => 'access_token_id', :class_name => 'AccessToken'
    has_many :users, :through => :camera_shares, :foreign_key => 'user_id', :class_name => 'User'
  end
end