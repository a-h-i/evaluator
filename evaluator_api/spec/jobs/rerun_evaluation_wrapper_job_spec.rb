require 'rails_helper'

RSpec.describe RerunEvaluationWrapperJob, type: :job do
    let(:project) do
      FactoryGirl.create(:project, published: true,
        course: FactoryGirl.create(:course, published: true))
    end
    let(:submission){ FactoryGirl.create(:submission_with_code, project: project) }
    let(:track_key) { (0...10).map { ('a'..'z').to_a[rand(26)] }.join}

    it 'should perform evaluation synchronosly' do
      expect(SubmissionEvaluationJob).to receive(:perform_now).once
      expect(project).to_not receive(:save!)
      expect(project).to_not receive(:save)
      RerunEvaluationWrapperJob.perform_now(submission, track_key, project)
    end

    it 'stops reruning when done' do
      $redis.set track_key, 2
      submissions = [submission, FactoryGirl.create(:submission_with_code,
        project: project)]
      project.reruning_submissions = true
      expect(SubmissionEvaluationJob).to receive(:perform_now).twice
      expect(project).to receive(:save!).once
      expect(project).to receive(:reruning_submissions=).with(false).once
      submissions.each { |s| RerunEvaluationWrapperJob.perform_now(submission, track_key, project) }
      expect($redis.get(track_key)).to eql "0"
    end
end
