class SubmissionsCullingJob < ApplicationJob
  queue_as :cleanup

  def perform(submitter, project)
    Submission.transaction do
      submissions = Submission.where(submitter: submitter,
                                     project: project).order(created_at: :desc).offset(
        Rails.application.config.configurations[:max_num_submissions]
      ).lock("FOR UPDATE")
      submissions.each(&:destroy)
    end
  end
end
