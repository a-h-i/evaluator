

class MessagingService
  MESSAGE_TYPE_SINGLE_SUBMISSION = 0x04
  def self.send_reset_email(email, data)
    UserMailer.pass_reset_email(email, data).deliver_later
  end

  def self.send_verification_email(email, data)
    UserMailer.verification_email(email, data).deliver_later
  end

  def self.queue_submission_eval_job(submission)
    message = submission_eval_message(submission.id)
    redis.lpush message_queue, message
  end
  def self.queue_submission_cul_job(user, project)
    SubmissionsCullingJob.perform_later(user.id, project.id)
  end
protected
  def self.submission_eval_message(submission_id)
    {
      message_type: MESSAGE_TYPE_SINGLE_SUBMISSION,
      submission_id: submission_id,
      sent_at: Time.now.iso8601
    }
  end
  def self.redis
    Rails.application.config.messaging_redis
  end
  def self.message_queue
    Rails.application.config.evaluator_message_queue
  end
end