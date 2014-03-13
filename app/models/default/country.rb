module Default
  class Country < DbBase
    self.table_name = 'countries'
    self.inheritance_column = 'ruby_type'
    self.primary_key = 'id'

    if ActiveRecord::VERSION::STRING < '4.0.0' || defined?(ProtectedAttributes)
      attr_accessible :created_at, :updated_at, :iso3166_a2, :name
    end

    has_many :users, :foreign_key => 'country_id', :class_name => 'User'
  end
end