require 'net/http'
class VerificationService
  RECAPTCHA_URL = 'https://www.google.com/recaptcha/api/siteverify'

  def initialize(captcha_params, ip)
    @captcha_params = captcha_params
    @remote_ip = ip
  end

  def self.verify_captcha(captcha_params, ip)
    instance = new(captcha_params, ip)
    instance.verify?
  end


  def verify?
    paramaters = {
      secret: Rails.application.credentials.recaptcha_secret_key,
      response: @captcha_params
    }
    paramaters[:ip] = @remote_ip unless @remote_ip.nil?
    uri = URI(RECAPTCHA_URL)
    req = Net::HTTP::Post.new(uri)
    req.body = paramaters.to_json
    req['Content-Type'] = 'application/json'
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request req
    end
    unless res.is_a?(Net::HTTPSuccess)
      message = "[#{self.class.to_s}] Non success response\n"
      message << "class " <<  res.class.to_s << " code #{res.code} \n"
      message << res.body << "\n"
      logger.error message
      return false
    end
    body = JSON.parse(res.body)
    return body['success']
  end



end