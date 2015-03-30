class Billing < ActiveRecord::Base
  self.table_name = 'billing'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'
end