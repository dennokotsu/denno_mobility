class User < ApplicationRecord
  belongs_to :company

  has_secure_password validations: true
  has_one_attached :avatar
  has_many :slips
  has_many :reports
  has_many :group_users

  validates :identifier, presence: true, uniqueness: { scope: :company_id }
  validates :company_id, presence: true
  validates :name, presence: true
  validates :role, presence: true

  def self.new_authentication_token
    SecureRandom.urlsafe_base64
  end

  def self.token_digest(token)
    Digest::SHA256.hexdigest(token.to_s)
  end

  # アカウントロック処理
  def authenticated_locked
    return false if self[:authentication_data].blank?
    return false if self[:authentication_data]["error_count"].blank?
    return false if self[:authentication_data]["error_count"] < USER_AUTHENTICATION_LOCK_COUNT

    true
  end

  def authenticated_lock_countup
    self[:authentication_data] = {} if self[:authentication_data].blank?
    self[:authentication_data]["error_count"] =
      self[:authentication_data]["error_count"].present? ? self[:authentication_data]["error_count"] + 1 : 1
    save
  end

  def authenticated_lock_unlock
    return if self[:authentication_data].blank?
    return if self[:authentication_data]["error_count"].blank?

    self[:authentication_data]["error_count"] = nil
    save
  end
end
