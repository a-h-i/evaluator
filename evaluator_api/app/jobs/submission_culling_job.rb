class SubmissionCullingJob < ActiveJob::Base
  queue_as :default

  def perform(user, project)
    submissions = Submission.where(submitter: user,
                                   project: project).order(created_at: :desc).offset(
                                     Rails.application.config.configurations[:max_num_submissions]
                                   ).lock('FOR UPDATE').each(&:destroy)
  end
end
