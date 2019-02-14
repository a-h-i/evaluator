
module JwtAuthenticatable
  extend ActiveSupport::Concern
  include PasswordHashable

  module ClassMethods
    def jwt_hash_key
      [Rails.application.credentials.jwt_hash_key].pack("h*")
    end

    def decode_token(token)
      decoded = JWT.decode token, jwt_hash_key, true, algorithm: "HS512"
      data = decoded.first["data"]
      resource = cache_fetch(data["id"]) { find(data["id"]) }
      raise AuthenticationError unless Rack::Utils.secure_compare(resource.password_hash, data["discriminator"])
      [resource, data["exp"]]
    end

    # Retrieve user based on token
    # Raises JWT::VerificationError if key missmatch or signature corrupted
    # Raises JWT::ExpiredSignature
    # Both subclasses of JWT::DecodeError
    # Raises ActiveRecord::RecordNotFound if user no longer exists
    # Raises AuthenticationError if incorrect authentication data supplied
    # returns User instance
    def find_by_token(token)
      resource = cache_read token
      if resource.nil?
        resource, exp = decode_token token
        return resource if exp.nil?
        unless exp < 0
          $redis.set token, Marshal.dump(self)
          $redis.expire token, exp
          cache_write token, expires_in: exp - Time.now.to_i
        end
      end
      resource
    end
  end

  # Generates a timed JWT
  # expiration unit is hours
  # default is 1 hour
  def token(expiration = 1)
    payload = {
      data: {
        id: id,
        discriminator: password_hash,
      },
      exp: Time.now.to_i + expiration.hours,
      iat: Time.now.to_i,
    }
    token = JWT.encode payload, self.class.jwt_hash_key, "HS512"
    self.class.cache_write token, self, expires_in: expiration.hours
    token
  end
end
