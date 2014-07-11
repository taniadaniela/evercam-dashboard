class DashSnapshot < ActiveRecord::Base
  self.table_name = 'snapshots'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'

  belongs_to :camera, :foreign_key => 'camera_id', :class_name => 'DashCamera'
  # has_many :access_rights, :foreign_key => 'snapshot_id', :class_name => 'AccessRight'
  # has_many :cameras, :through => :access_rights, :foreign_key => 'camera_id', :class_name => 'DashCamera'
end
