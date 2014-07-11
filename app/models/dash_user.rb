class DashUser < ActiveRecord::Base
  attr_protected :admin
  self.table_name = 'users'
  self.inheritance_column = 'ruby_type'
  self.primary_key = 'id'

  # belongs_to :country, :foreign_key => 'country_id', :class_name => 'Country'
  # has_many :access_tokens, :foreign_key => 'user_id', :class_name => 'AccessToken'
  # has_many :camera_share_requests, :foreign_key => 'user_id', :class_name => 'CameraShareRequest'
  # has_many :camera_shares, :foreign_key => 'user_id', :class_name => 'CameraShare'
  # has_many :clients, :through => :access_tokens, :foreign_key => 'client_id', :class_name => 'Client'
  # has_many :cameras_by_camera_share_requests, :source => :camera, :through => :camera_share_requests, :foreign_key => 'camera_id', :class_name => 'Camera'
  # has_many :cameras_by_camera_shares, :source => :camera, :through => :camera_shares, :foreign_key => 'camera_id', :class_name => 'Camera'

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
