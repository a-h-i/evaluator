require 'digest'
module PasswordHashable
  extend ActiveSupport::Concern
  include Cachable

  attr_reader :password

  def password=(unencrypted_password)
    if unencrypted_password.nil?
      self.password_digest = nil
    elsif !unencrypted_password.empty?
      argon = Argon2::Password.new(t_cost: config.argon_t_cost, m_cost: config.argon_m_cost, secret: self.class.pass_hash_key)
      self.password_digest = argon.create(unencrypted_password)
    end
  end

  def authenticate?(unencrypted_password)
    Argon2::Password.verify_password(unencrypted_password, self.password_digest, self.class.pass_hash_key)
  end

  def password_hash
    Digest::SHA512.hexdigest password_digest
  end

  module ClassMethods
    def login(email, password)
      login_key = get_cache_key(email: email)
      resource = cache_fetch(login_key) do
        self.class.find_by email: email, verified: true
      end
      raise AuthenticationError unless resource.authenticate?(password)
      raise ForbiddenError unless resource.allowed_login?
      resource
    end

    def pass_hash_key
      key = Rails.application.credentials.password_hash_key
      key = [key].pack("h*")
    end
  end

  included do
    validate do |record|
      record.errors.add(:password, :blank) unless record.password_digest.present?
    end
  end
end
