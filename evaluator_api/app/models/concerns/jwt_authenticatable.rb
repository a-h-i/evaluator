
module JwtAuthenticatable
  extend ActiveSupport::Concern
  include PasswordHashable

  module ClassMethods
    def jwt_hash_key
      [Rails.application.credentials.jwt_hash_key].pack("h*")
    end

    # Raises JWT::VerificationError if key missmatch or signature corrupted
    # Raises JWT::ExpiredSignature
    # Both subclasses of JWT::DecodeError
    # Raises ActiveRecord::RecordNotFound if JwtAuthenticatable no longer exists
    # Raises AuthenticationError if incorrect authentication data supplied
    # returns resource, expiration_in_seconds
    def decode_token(token)
      decoded = JWT.decode(token, jwt_hash_key, true, {algorithm: "HS512", verify_iat: true})
      data = decoded.first["data"]
      resource = cache_fetch({id: data["id"]}) { find(data["id"]) }
      raise AuthenticationError unless Rack::Utils.secure_compare(resource.password_hash, data["discriminator"])
      [resource, data["exp"]]
    end

    # Retrieve user based on token
    # Raises JWT::VerificationError if key missmatch or signature corrupted
    # Raises JWT::ExpiredSignature
    # Both subclasses of JWT::DecodeError
    # Raises ActiveRecord::RecordNotFound if user no longer exists
    # Raises AuthenticationError if incorrect authentication data supplied
    # returns JwtAuthenticatable instance
    # return nil if token not associated with user
    def find_by_token(token)
      resource = cache_fetch({ token: token }) do
        resource, exp = decode_token token
        return resource if exp.nil?
        expires_in = exp - Time.now.to_i
        resource.add_related_cache_key({token: token})
        return resource, expires_in
      end
      
    end
  end

  # Generates a timed JWT
  # expiration unit is hours
  # default is 1 hour
  def token(expiration = nil)
    expiration ||= 1
    payload = {
      data: {
        id: id,
        discriminator: password_hash,
      },
      exp: Time.now.to_i + expiration.hours,
      iat: Time.now.to_i,
    }
    token = JWT.encode payload, self.class.jwt_hash_key, "HS512"
    self.class.cache_write({ token: token }, self, expires_in: expiration.hours)
    self.add_related_cache_key({token: token})
    token
  end
end
