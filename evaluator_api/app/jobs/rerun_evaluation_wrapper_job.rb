class RerunEvaluationWrapperJob < ActiveJob::Base
  queue_as :default

  def perform(submission, track_key, project)
    SubmissionEvaluationJob.perform_now(submission)
    new_value = $redis.decr track_key
    if new_value <= 0 && project.reruning_submissions
      project.reruning_submissions = false
      project.save!
    end
  end
end
