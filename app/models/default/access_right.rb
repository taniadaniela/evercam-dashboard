module Default
  class AccessRight < DbBase
    self.table_name = 'access_rights'
    self.inheritance_column = 'ruby_type'
    self.primary_key = 'id'

    if ActiveRecord::VERSION::STRING < '4.0.0' || defined?(ProtectedAttributes)
      attr_accessible :created_at, :updated_at, :token_id, :right, :camera_id, :grantor_id, :status
    end

    belongs_to :camera, :foreign_key => 'camera_id', :class_name => 'Camera'
  end
end