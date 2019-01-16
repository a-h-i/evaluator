require 'rails_helper'

RSpec.describe ProjectBundleJob, type: :job do
  before :each do
    @project = FactoryGirl.create(:project, published: true, course: FactoryGirl.create(:course, published: true))
    @setup_submissions = lambda do
      submitter_one = FactoryGirl.create(:student, verified: true)
      submitter_two = FactoryGirl.create(:student, verified: true)
      submitter_three = FactoryGirl.create(:student, verified: true)
      submitter_four = FactoryGirl.create(:student, verified: true)

      submissions_one = FactoryGirl.create_list(:submission_with_code, 30, project: @project, submitter: submitter_one)
      submissions_two = FactoryGirl.create_list(:submission_with_code, 30, project: @project, submitter: submitter_two)
      submissions_thre = FactoryGirl.create_list(:submission_with_code, 30, project: @project, submitter: submitter_three)
      submissions_four = FactoryGirl.create_list(:submission_with_code, 30, project: @project, submitter: submitter_four)
    end
  end
  it 'sends notification' do
    @setup_submissions.call
    bundle = FactoryGirl.create(:project_bundle, project: @project)
    expect(@project).to receive(:notify_bundle_ready).once
    ProjectBundleJob.perform_now(bundle, false)
  end
end
