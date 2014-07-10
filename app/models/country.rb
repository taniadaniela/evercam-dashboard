class Country < LegacyBase
  self.table_name = 'countries'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'

  has_many :users, :foreign_key => 'country_id', :class_name => 'User'
end
