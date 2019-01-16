# == Schema Information
#
# Table name: suite_cases
#
#  id            :integer          not null, primary key
#  grade         :integer          default(0), not null
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  test_suite_id :integer
#
# Indexes
#
#  index_suite_cases_on_name           (name)
#  index_suite_cases_on_test_suite_id  (test_suite_id)
#
# Foreign Keys
#
#  fk_rails_...  (test_suite_id => test_suites.id) ON DELETE => cascade
#

FactoryGirl.define do
  factory :suite_case do
    test_suite { FactoryGirl.create(:test_suite) }
    name 'testName'
    grade 1
  end
end
