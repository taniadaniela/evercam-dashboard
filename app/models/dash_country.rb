class DashCountry < ActiveRecord::Base
  self.table_name = 'countries'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'

  has_many :dash_users, class_name: 'DashUser', foreign_key: 'id'

  attr_protected :admin
end
