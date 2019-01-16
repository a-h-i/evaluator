class RerunSubmissionsJob < ActiveJob::Base
  queue_as :default

  def perform(project)
    submissions = Submission.newest_per_submitter_of_project(project)
    enumerator = LowerCaseEnumerator.new([])
    track_key = enumerator.get_token until $redis.setnx(track_key,
                                                        submissions.count)
    submissions.each do |s|
      RerunEvaluationWrapperJob.perform_later(s, track_key, project)
    end
  end
end
