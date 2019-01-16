require 'rails_helper'

RSpec.describe SubmissionCullingJob, type: :job do
  before :each do
    # setup project
    @project = FactoryGirl.create(:project, published: true,
                                            course: FactoryGirl.create(:course, published: true))
    # Setup test suite
    @suite = TestSuite.new
    @suite.project = @project
    @suite.name = 'csv_test_suite'
    @suite.save!
    code = SuiteCode.new
    code.code = IO.binread(File.join(Rails.root, 'spec', 'fixtures',
                                     '/files/test_suites/csv_test_suite.zip'))
    code.file_name = 'csv_test_suite.zip'
    code.mime_type = Rack::Mime.mime_type '.zip'
    code.test_suite = @suite
    code.save!
    # Run process job
    SuitesProcessJob.perform_now @suite
    @create_submission = lambda do |submitter|
      submission = Submission.new
      submission.submitter = submitter
      submission.project = @project
      submission.save!
      solution = Solution.new
      solution.file_name = 'csv_submission_correct.zip'
      solution.mime_type = Rack::Mime.mime_type '.zip'
      solution.submission = submission
      solution.code = IO.binread(File.join(Rails.root, 'spec', 'fixtures',
                                           'files', 'submissions', 'csv_submission_correct.zip'))
      solution.save!
      SubmissionEvaluationJob.perform_now submission
      submission
    end
  end

  it 'keeps only the most recent' do
    max_num_submissions = Rails.application.config.configurations[:max_num_submissions]
    submitter = FactoryGirl.create(:student, verified: true)
    20.times { @create_submission.call(submitter) }
    ids = submitter.submissions.order(created_at: :desc).limit(
      max_num_submissions
    ).to_a.map(&:id)
    expect do
      SubmissionCullingJob.perform_now submitter, @project
    end.to change(Submission, :count).by(-(20 - max_num_submissions))
    keptIds = submitter.submissions.to_a.reduce(true) do |memo, submission|
      memo && ids.include?(submission.id)
    end
    expect(keptIds).to be true
  end

  it 'does nothing if less than max_num_submissions' do
    max_num_submissions = Rails.application.config.configurations[:max_num_submissions]
    submitter = FactoryGirl.create(:student, verified: true)
    3.times { @create_submission.call(submitter) }
    expect do
      SubmissionCullingJob.perform_now submitter, @project
    end.to change(Submission, :count).by(0)
  end
end
