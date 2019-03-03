# == Schema Information
#
# Table name: results
#
#  id            :bigint(8)        not null, primary key
#  submission_id :bigint(8)        not null
#  project_id    :bigint(8)        not null
#  test_suite_id :bigint(8)        not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  max_grade     :integer          not null
#  grade         :integer          not null
#  success       :boolean          not null
#  hidden        :boolean          not null
#  detail        :jsonb            not null
#
# Indexes
#
#  index_results_on_submission_id  (submission_id)
#

FactoryBot.define do
  factory :result do
    success { true }
    grade { 10 }
    max_grade { 30 }
    project do
      FactoryBot.create(:project,
                        published: true, course: FactoryBot.create(:course, published: true))
    end
    detail { FactoryBot.create }
    after(:build) do |result|
      if result.test_suite.nil?
        result.test_suite = FactoryBot.create(:public_suite, project: result.project)
      end
      if result.submission.nil?
        result.submission = FactoryBot.create(:submission, project: result.project)
      end
    end
  end
end
