

class MessagingService

  def self.send_reset_email(email, data)
    UserMailer.pass_reset_email(email, data).deliver_later
  end

  def self.send_verification_email(email, data)
  end

  def self.queue_submission_eval_job(submission)
  end
  def self.queue_submission_cul_job(user, project)
    SubmissionsCullingJob.perform_later(user.id, project.id)
  end
end