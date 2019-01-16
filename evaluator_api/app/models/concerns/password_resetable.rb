# Password Reset concern for User model.
module PasswordResetable
  extend ActiveSupport::Concern

  module ClassMethods
    def pass_reset_expiration
      Rails.application.config.configurations[:pass_reset_expiration]
    end

    def pass_reset_token_str_max_length
      Rails.application.config.pass_reset_token_str_max_length
    end

    def pass_resend_delay
      Rails.application.config.configurations[:pass_reset_resend_delay]
    end
  end
  included do
    has_many :reset_tokens, dependent: :delete_all
  end

  def can_resend_reset?
    expiration_time = User.pass_resend_delay.ago
    num_tokens = ResetToken.where(user_id: id).where('created_at > ?',
                                                     expiration_time)
                           .count
    num_tokens == 0
  end

  def reset_password(token, new_pass)
    with_lock('FOR UPDATE') do
      expiration_time = User.pass_reset_expiration.ago
      reset_tokens = ResetToken.where(user_id: id,
                                      token: token).where('created_at >= ?',
                                                          expiration_time)
      if reset_tokens.count > 0
        self.password = new_pass
        save!
        reset_tokens.delete_all
        return true
      else
        return false
      end
    end
  end

  def gen_reset_token
    reset_token = with_lock('FOR UPDATE') do
      expiration_time = User.pass_reset_expiration.ago
      ResetToken.where(user_id: id).where('created_at <= ?',
                                          expiration_time).delete_all
      ResetToken.where(user_id: id).order(
        created_at: :desc).offset(1).destroy_all
      token = ResetToken.where(user_id: id).order(
        created_at: :desc).first
      token_str = SecureRandom.urlsafe_base64(
        User.pass_reset_token_str_max_length)
      if !token.nil? && token.created_at <= expiration_time
        token.destroy
        token = nil
      end
      token || ResetToken.create(user: self, token: token_str)
    end
    reset_token.token
  end
end
