module Default
  class CameraShare < DbBase
    self.table_name = 'camera_shares'
    self.inheritance_column = 'ruby_type'
    self.primary_key = 'id'

    if ActiveRecord::VERSION::STRING < '4.0.0' || defined?(ProtectedAttributes)
      attr_accessible :camera_id, :user_id, :sharer_id, :kind, :created_at, :updated_at
    end

    belongs_to :camera, :foreign_key => 'camera_id', :class_name => 'Camera'
    belongs_to :user, :foreign_key => 'user_id', :class_name => 'User'
  end
end