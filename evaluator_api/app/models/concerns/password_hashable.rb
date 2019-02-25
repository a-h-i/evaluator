require 'digest'
module PasswordHashable
  extend ActiveSupport::Concern
  include ActiveModel::Validations
  include Cachable

  attr_accessor :password

  def hash_password
    if password.present? && !password.empty?
      config = Rails.application.config.argon
      argon = Argon2::Password.new(t_cost: config[:t_cost], m_cost: config[:m_cost], secret: self.class.pass_hash_key)
      self.password_digest = argon.create(password)
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
      resource = cache_fetch({email: email}) do
        resource = find_by(email: email)
        resource.add_related_cache_key({email: email})
      end
      resource = resource
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
    validates :password, length: { minimum: 2 }, allow_nil: true
    validate do |record|
      record.errors.add(:password, :blank) if record.password_digest.nil? && password.nil?
    end
    before_save :hash_password
  end
end
