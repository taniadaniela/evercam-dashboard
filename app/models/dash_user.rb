class DashUser < ActiveRecord::Base
  attr_protected :admin
  self.table_name = 'users'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'

  def self.by_login(val)
    where(username: val).or(email: val).first
  end

  def fullname
    [firstname, lastname].join(' ')
  end

  def password
    BCrypt::Password.new(self[:password])
  end

  def password=(val)
    self[:password] = BCrypt::Password.create(val, cost: 10)
  end

  def confirmed?
    false == self.confirmed_at.nil?
  end

  def allow?(right, token)
    return true if token &&
    token.user == self
  end

  def validate
    super
    errors.add(:firstname, "is invalid") if (/^[\w\s]+$/ =~ firstname).nil?
    errors.add(:lastname, "is invalid") if (/^[\w\s]+$/ =~ lastname).nil?
    errors.add(:username, "is invalid") if (/^[\w\s]+$/ =~ username).nil?
    errors.add(:email, "is invalid") if (/^.+@.+\..+$/ =~ email).nil?
  end

  private

  def ensure_token_exists
    self.token ||= AccessToken.new(
      expires_at: Time.at(2**31))
  end

end
