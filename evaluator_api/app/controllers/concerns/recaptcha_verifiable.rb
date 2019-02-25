

module RecaptchaVerifiable
  extend ActiveSupport::Concern


  def verify_captcha
    captcha_params = params.require(:recaptcha)
    ip = if Rails.env.production?
      request.headers['X-Forwarded-For'].split(',').first
    else
      nil
    end
    raise CaptchaError unless VerificationService.verify_captcha(captcha_params, ip)
  end
end