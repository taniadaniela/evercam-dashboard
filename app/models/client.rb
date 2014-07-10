class Client < LegacyBase
  self.table_name = 'clients'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'

  has_many :access_tokens, :foreign_key => 'client_id', :class_name => 'AccessToken'
  has_many :users, :through => :access_tokens, :foreign_key => 'user_id', :class_name => 'User'
end
