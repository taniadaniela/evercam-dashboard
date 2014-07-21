class DashUser < ActiveRecord::Base
  attr_protected :admin
  self.table_name = 'users'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'

  belongs_to :dash_country, class_name: 'DashCountry', foreign_key: 'country_id', primary_key: 'id'
  has_many :dash_cameras, :foreign_key => 'owner_id', :class_name => 'DashCamera'
  has_many :dash_cameras_by_dash_camera_shares, :source => :dash_camera, :through => :dash_camera_shares, :foreign_key => 'camera_id', :class_name => 'DashCamera'
  has_many :dash_camera_shares, :foreign_key => 'user_id', :class_name => 'DashCameraShare'

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
