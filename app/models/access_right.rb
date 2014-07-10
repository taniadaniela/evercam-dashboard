class AccessRight < LegacyBase
  self.table_name = 'access_rights'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'

  belongs_to :camera, :foreign_key => 'camera_id', :class_name => 'Camera'
  belongs_to :snapshot, :foreign_key => 'snapshot_id', :class_name => 'Snapshot'
end
