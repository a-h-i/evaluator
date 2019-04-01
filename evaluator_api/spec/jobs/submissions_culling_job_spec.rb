require "rails_helper"

RSpec.describe SubmissionsCullingJob, type: :job do
  let(:published_course) { FactoryBot.create(:course, published: true) }
  let(:project) { FactoryBot.create(:project, course: published_course, published: true) }
  let(:student) { FactoryBot.create(:student) }
  it "keeps only the most recent" do
    max = Rails.application.config.configurations[:max_num_submissions]
    created = max * 2
    published_course.register student
    submissions = FactoryBot.create_list(:submission, created, project: project, submitter: student)
    expect(Submission.count).to be > max
    ids = student.submissions.order(created_at: :desc).limit(
      max
    ).pluck(:id)
    expect do
      SubmissionsCullingJob.perform_now(student.id, project.id)
    end.to change(Submission, :count).by(-(created - max))
    keptIds = student.submissions.order(created_at: :desc).pluck(:id)
    expect(keptIds).to match_array ids
  end

  it 'does nothing if less than max_num_submissions' do
    max_num_submissions = Rails.application.config.configurations[:max_num_submissions]
    FactoryBot.create_list(:submission, max_num_submissions, project: project, submitter: student)
    expect do
      SubmissionsCullingJob.perform_now student.id, project.id
    end.to change(Submission, :count).by(0)
  end
end
