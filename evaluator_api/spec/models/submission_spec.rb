# == Schema Information
#
# Table name: submissions
#
#  id           :integer          not null, primary key
#  team         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  project_id   :integer
#  submitter_id :integer          not null
#
# Indexes
#
#  index_submissions_on_created_at           (created_at)
#  index_submissions_on_project_id           (project_id)
#  index_submissions_on_project_id_and_team  (project_id,team)
#  index_submissions_on_submitter_id         (submitter_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id) ON DELETE => cascade
#  fk_rails_...  (submitter_id => users.id) ON DELETE => cascade
#

require 'rails_helper'

RSpec.describe Submission, type: :model do
  it { should belong_to :project }
  it { should belong_to :submitter }
  it { should have_one :solution }
  it { should have_many :results }
  it { should validate_presence_of :project }
  it { should validate_presence_of :submitter }

  it 'does not submit to a due project' do
    project = FactoryGirl.create(:project, published: true,
    due_date: DateTime.now.utc - 1.day,
    course: FactoryGirl.create(:course, published: true)
    )
    submission = FactoryGirl.build(:submission, project: project)
    expect(submission).to_not be_valid
    expect(submission.errors[:project]).to contain_exactly('Must be before deadline and after start date')
  end

  it 'has a valid factory' do
    submission = FactoryGirl.build(:submission)
    expect(submission).to be_valid
  end
  context 'notifications' do
    it 'sends deleted notification' do
      submission = FactoryGirl.create(:submission)
      expect(Notifications::SubmissionsController).to receive(:publish).once
      submission.destroy
    end
  end

  context 'newest_per_submitter_of_project' do
    it 'There are four results' do
      project = FactoryGirl.create(:project, published: true, course: FactoryGirl.create(:course, published: true))
      submitter_one = FactoryGirl.create(:student, verified: true)
      submitter_two = FactoryGirl.create(:student, verified: true)
      submitter_three = FactoryGirl.create(:student, verified: true)
      submitter_four = FactoryGirl.create(:student, verified: true)

      submissions_one = FactoryGirl.create_list(:submission_with_code, 30, project: project, submitter: submitter_one)
      submissions_two = FactoryGirl.create_list(:submission_with_code, 30, project: project, submitter: submitter_two)
      submissions_thre = FactoryGirl.create_list(:submission_with_code, 30, project: project, submitter: submitter_three)
      submissions_four = FactoryGirl.create_list(:submission_with_code, 30, project: project, submitter: submitter_four)

      expect(Submission.newest_per_submitter_of_project(project).count).to eql 4
    end
  end

  context 'newest_per_team_of_project' do
    before :each do
      @project_one = FactoryGirl.create(:project, published: true, course: FactoryGirl.create(:course, published: true))
      @project_two = FactoryGirl.create(:project, published: true, course: FactoryGirl.create(:course, published: true))
      @create_team_grade = lambda do |team_name, project|
        submitter = FactoryGirl.create(:student, team: team_name)
        submission = FactoryGirl.create(:submission_with_code, submitter: submitter, project: project)
        result = FactoryGirl.create(:result, submission: submission, project: project)
      end
    end

    it 'returns all teams' do
      @create_team_grade.call('one', @project_one)
      @create_team_grade.call('two', @project_one)
      @create_team_grade.call('three', @project_one)
      @create_team_grade.call('four', @project_two)
      expect(Submission.newest_per_team_of_project(@project_one).size).to eql 3
    end

    it 'returns one per team' do
      @create_team_grade.call('one', @project_two)
      @create_team_grade.call('one', @project_two)
      expect(Submission.newest_per_team_of_project(@project_two).size).to eql 1
    end
  end
end
