module Default
  class Client < DbBase
    self.table_name = 'clients'
    self.inheritance_column = 'ruby_type'
    self.primary_key = 'id'

    if ActiveRecord::VERSION::STRING < '4.0.0' || defined?(ProtectedAttributes)
      attr_accessible :created_at, :updated_at, :exid, :callback_uris, :secret, :name
    end

    has_many :access_tokens, :foreign_key => 'client_id', :class_name => 'AccessToken'
    has_many :users, :through => :access_tokens, :foreign_key => 'user_id', :class_name => 'User'
  end
end