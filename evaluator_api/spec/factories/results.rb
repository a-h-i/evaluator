# == Schema Information
#
# Table name: results
#
#  id              :integer          not null, primary key
#  compiled        :boolean          not null
#  compiler_stderr :text             not null
#  compiler_stdout :text             not null
#  grade           :integer          not null
#  hidden          :boolean          not null
#  max_grade       :integer          not null
#  success         :boolean          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  project_id      :integer
#  submission_id   :integer
#  test_suite_id   :integer
#
# Indexes
#
#  index_results_on_project_id     (project_id)
#  index_results_on_submission_id  (submission_id)
#  index_results_on_test_suite_id  (test_suite_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id) ON DELETE => cascade
#  fk_rails_...  (submission_id => submissions.id) ON DELETE => cascade
#  fk_rails_...  (test_suite_id => test_suites.id) ON DELETE => cascade
#

FactoryGirl.define do
  factory :result do
    compiled true
    compiler_stderr 'stderr'
    compiler_stdout 'stdout'
    success true
    grade 10
    max_grade 30
    project do
      FactoryGirl.create(:project,
                         published: true, course: FactoryGirl.create(:course, published: true))
    end
    after(:build) do |result|
      if result.test_suite.nil?
        result.test_suite = FactoryGirl.create(:public_suite, project: result.project)
      end
      if result.submission.nil?
        result.submission = FactoryGirl.create(:submission, project: result.project)
      end
    end
  end
end
