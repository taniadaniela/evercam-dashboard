class DashCountry < ActiveRecord::Base
  self.table_name = 'countries'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'

  attr_protected :admin
end
