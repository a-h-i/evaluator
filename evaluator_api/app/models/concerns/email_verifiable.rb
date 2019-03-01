module EmailVerifiable
  extend ActiveSupport::Concern
  included do
    scope :verified, -> { where verified: true }
  end

  def send_verification_email
   
    encrypted = gen_email_verification_token
    MessagingService.send_verification_email(email, encrypted)
  end

  def gen_email_verification_token
    data = {
      id: id,
      email: email,
      reset: false,
      verify: true,
    }
    aes = AESEncryptService.new
    aes.encrypt(data)
  end

  module ClassMethods
    def verify_email_token(data)
      aes = AESEncryptService.new
      plain = aes.decrypt(data)
      return nil unless plain["verify"]
      instance = find(plain["id"])
      instance.verified = true
      instance.save!
      instance
    end
  end
end
