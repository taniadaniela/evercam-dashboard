class DashCamera < ActiveRecord::Base
  self.table_name = 'cameras'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'

  attr_protected :admin

  belongs_to :dash_vendor_model, class_name: 'DashVendorModel', foreign_key: 'model_id', primary_key: 'id'
  belongs_to :dash_user, class_name: 'DashUser', foreign_key: 'owner_id', primary_key: 'id'
  has_many :dash_camera_shares, :foreign_key => 'camera_id', :class_name => 'DashCameraShare'
end
