class DashCamera < ActiveRecord::Base
  self.table_name = 'cameras'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'

  attr_protected :admin
end
