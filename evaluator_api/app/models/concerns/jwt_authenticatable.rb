# Concern for User class JWT authentication.
module JwtAuthenticatable
  extend ActiveSupport::Concern

  module ClassMethods
    def decode_token(token)
      decoded = JWT.decode token, hmac_key, true, algorithm: 'HS512'
      data = decoded.first['data']
      user = find data['id']
      raise AuthenticationError unless Rack::Utils.secure_compare(
        user.password_digest, data['discriminator'])
      [user, data['exp']]
    end

    # Retrieve user based on token
    # Raises JWT::VerificationError if key missmatch or signature corrupted
    # Raises JWT::ExpiredSignature
    # Both subclasses of JWT::DecodeError
    # Raises ActiveRecord::RecordNotFound if user no longer exists
    # Raises AuthenticationError if incorrect authentication data supplied
    # returns User instance
    def find_by_token(token)
      cached = $redis.get token
      if cached.nil?
        record, exp = decode_token(token)
        return record if exp.nil?
        exp -= Time.now.to_i
        unless exp < 0
          $redis.set token, Marshal.dump(self)
          $redis.expire token, exp
        end
        record
      else
        Marshal.load(cached)
      end
    end

    def hmac_key
      Rails.application.config.jwt_key
    end
  end

  included do
    has_many :verification_tokens, dependent: :delete_all
  end

  # Generates a timed JWT
  # expiration unit is hours
  # default is 1 hour
  def token(expiration = nil)
    expiration ||= 1
    payload = {
      data: {
        id: id,
        discriminator: password_digest
        # discriminator used to detect password changes after token generation
      },
      exp: Time.now.to_i + expiration.hours
    }
    # HMAC using SHA-512 algorithm
    token = JWT.encode payload, User.hmac_key, 'HS512'
    $redis.set token, Marshal.dump(self)
    $redis.expire token, expiration.hours
    self.class.add_related_cache(id, token)
    token
  end
end
