module Default
  class Snapshot < DbBase
    self.table_name = 'snapshots'
    self.inheritance_column = 'ruby_type'
    self.primary_key = 'id'

    if ActiveRecord::VERSION::STRING < '4.0.0' || defined?(ProtectedAttributes)
      attr_accessible :camera_id, :created_at, :notes, :data
    end

    belongs_to :camera, :foreign_key => 'camera_id', :class_name => 'Camera'
  end
end