class SubjectTaggerEmailInterceptor
  def self.delivering_email(message)
    message.subject = "[EVALUATOR] " + message.subject
  end

  def self.previewing_email(message)
    delivering_email message
  end
end

ActionMailer::Base.register_interceptor SubjectTaggerEmailInterceptor
ActionMailer::Base.register_preview_interceptor SubjectTaggerEmailInterceptor

Rails.application.configure do
  unless Rails.env.test?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smpt_settings = {
      address: ENV.fetch("EV_SMTP_HOST", "localhost"),
      port: ENV.fetch("EV_SMTP_PORT", 25),
    }
  end
end
