module Default
  class CameraActivity < DbBase
    self.table_name = 'camera_activities'
    self.inheritance_column = 'ruby_type'
    self.primary_key = 'id'

    if ActiveRecord::VERSION::STRING < '4.0.0' || defined?(ProtectedAttributes)
      attr_accessible :camera_id, :access_token_id, :action, :done_at, :ip
    end

    belongs_to :access_token, :foreign_key => 'access_token_id', :class_name => 'AccessToken'
    belongs_to :camera, :foreign_key => 'camera_id', :class_name => 'Camera'
  end
end