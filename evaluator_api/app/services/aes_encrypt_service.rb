require 'openssl'
require 'securerandom'

class AESEncryptService

  def initialize
    @cipher = OpenSSL::Cipher.new('aes-256-cbc')
  end

  def hmac_key
    [Rails.application.credentials.aes_encrypt_service_hmac_secret].pack("h*")
  end

  def key
    @key_ ||= [Rails.application.credentials.aes_encrypt_service_secret].pack('h*')
  end

  # plain must be a hash that does not have key :aes_encrypt_service_disc
  def encrypt(plain)
    plain[:aes_encrypt_service_disc] = SecureRandom.random_bytes(16).unpack('h*').first
    plain[:aes_hmac] = HmacService.hmac_hash(plain, hmac_key)
    alg = @cipher.encrypt
    alg.key = key
    iv = alg.iv = SecureRandom.random_bytes(16)
    encrypted = alg.update(plain.to_json) + alg.final
    encode(iv + encrypted)
  end

  def decrypt(encoded)
    decoded = decode(encoded)
    alg = @cipher.decrypt
    alg.key = key
    alg.iv = decoded[0..15]
    encrypted = decoded[16..-1]
    plain = alg.update(encrypted) + alg.final
    plain = JSON.parse(plain)
    hmac = plain["aes_hmac"]
    plain.delete "aes_hmac"
    raise ForbiddenError unless Rack::Utils.secure_compare(hmac, HmacService.hmac_hash(plain, hmac_key))
    return plain
  end

  def encode(data)
    Base64.urlsafe_encode64(data)
  end

  def decode(data)
    Base64.urlsafe_decode64(data)
  end
end