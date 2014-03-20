module Default
  class User < DbBase
    self.table_name = 'users'
    self.inheritance_column = 'ruby_type'
    self.primary_key = 'id'

    if ActiveRecord::VERSION::STRING < '4.0.0' || defined?(ProtectedAttributes)
      attr_accessible :created_at, :updated_at, :forename, :lastname, :username, :password, :country_id, :confirmed_at, :email, :reset_token, :token_expires_at, :api_id, :api_key
    end

    belongs_to :country, :foreign_key => 'country_id', :class_name => 'Country'
    has_many :access_tokens, :foreign_key => 'user_id', :class_name => 'AccessToken'
    has_many :camera_shares, :foreign_key => 'user_id', :class_name => 'CameraShare'
    has_many :clients, :through => :access_tokens, :foreign_key => 'client_id', :class_name => 'Client'
    has_many :cameras, :through => :camera_shares, :foreign_key => 'camera_id', :class_name => 'Camera'
  end
end