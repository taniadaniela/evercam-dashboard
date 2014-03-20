module Default
  class Snapshot < DbBase
    self.table_name = 'snapshots'
    self.inheritance_column = 'ruby_type'
    self.primary_key = 'id'

    if ActiveRecord::VERSION::STRING < '4.0.0' || defined?(ProtectedAttributes)
      attr_accessible :camera_id, :created_at, :notes, :data, :is_public
    end

    belongs_to :camera, :foreign_key => 'camera_id', :class_name => 'Camera'
    has_many :access_rights, :foreign_key => 'snapshot_id', :class_name => 'AccessRight'
    has_many :cameras, :through => :access_rights, :foreign_key => 'camera_id', :class_name => 'Camera'
  end
end