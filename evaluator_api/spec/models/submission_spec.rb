# == Schema Information
#
# Table name: submissions
#
#  id           :bigint(8)        not null, primary key
#  project_id   :bigint(8)        not null
#  submitter_id :bigint(8)        not null
#  course_id    :bigint(8)        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  mime_type    :text             not null
#  file_name    :text             not null
#  team         :text
#
# Indexes
#
#  index_submissions_on_submitter_id_and_project_id_and_created_at  (submitter_id,project_id,created_at)
#

require 'rails_helper'

RSpec.describe Submission, type: :model do
  let(:subject) { FactoryBot.create(:team_submission) }
  it { should belong_to :project }
  it { should belong_to :submitter }
  it { should have_many :results }
  
  it "sets course" do
    expect(subject.course).to be_truthy
  end

  it "sets mime type" do
    expect(subject.mime_type).to be_truthy
  end

  it "sets filename" do
    expect(subject.file_name).to be_truthy
  end

  it "sets team" do
    expect(subject.team).to eql StudentCourseRegistration.where(student_id: subject.submitter_id, course_id: subject.course_id).pluck(:team).first
  end

  it "saves file" do
    expect(File.exist?(subject.file_path)).to be true
  end

end
