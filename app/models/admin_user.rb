class AdminUser < LegacyBase
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  self.table_name = 'admin_users'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'
end
