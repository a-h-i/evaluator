require 'openssl'
class HmacService

  def self.hmac_hash(data, key)
    values = data.transform_keys(&:to_s).transform_values(&:to_s).values
    values.sort! do | (key_1, _), (key_2, _) |
      key_1 <=> key_2
    end
    hmac_str(values.join(''), key)
  end


  def self.hmac_str(data, key)
    OpenSSL::HMAC.hexdigest("SHA512", key, data)
  end
end