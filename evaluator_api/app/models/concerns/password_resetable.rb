module PasswordResetable
  extend ActiveSupport::Concern

  def send_reset_pass_email
    encrypted = gen_pass_reset_token
    MessagingService.send_reset_email(email, encrypted)
    encrypted
  end

  def gen_pass_reset_token
    data = {
      id: id,
      email: email,
      reset: true,
    }
    aes = AESEncryptService.new
    aes.encrypt(data)
  end

  module ClassMethods

    def confirm_reset(token, pass)
      aes = AESEncryptService.new
      data = aes.decrypt(token)
      return nil unless data["reset"]
      instance = find(data["id"])
      instance.password = pass
      instance.save
    rescue
      false
    end
  end
end
