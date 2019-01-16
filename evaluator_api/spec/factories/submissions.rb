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

FactoryGirl.define do
  factory :submission do
    project do
      FactoryGirl.create(:project, published: true,
        course: FactoryGirl.create(:course, published: true))
    end
    submitter { FactoryGirl.create(:student, verified: true) }

    factory :submission_with_code do
      after(:create) do |submission|
        submission.solution = FactoryGirl.create(:solution, submission: submission)
      end
    end
  end
end
