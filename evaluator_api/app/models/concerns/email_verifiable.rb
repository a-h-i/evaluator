module EmailVerifiable
  extend ActiveSupport::Concern
  included do
    scope :verified, -> { where verified: true }
  end

  def send_verification_email
    data = {
      id: id,
      email: email,
      reset: false,
      verify: true,
    }
    aes = AESEncryptService.new
    encrypted = aes.encrypt(data)
    MessagingService.send_verification_email(email, encrypted)
    encrypted
  end

  module ClassMethods
    def verify(data)
      aes = AESEncryptService.new
      plain = aes.decrypt(data)
      return nil unless plain["verify"]
      instance = find(plain["id"])
      instance.verified = true
      instance.save!
    end
  end
end
