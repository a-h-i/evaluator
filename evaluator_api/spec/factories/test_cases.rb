# == Schema Information
#
# Table name: test_cases
#
#  id              :integer          not null, primary key
#  detail          :text
#  grade           :integer          not null
#  java_klass_name :text
#  max_grade       :integer          not null
#  name            :string           not null
#  passed          :boolean          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  result_id       :integer
#
# Indexes
#
#  index_test_cases_on_result_id  (result_id)
#
# Foreign Keys
#
#  fk_rails_...  (result_id => results.id) ON DELETE => cascade
#

FactoryGirl.define do
  factory :test_case do
    result nil
    name 'MyString'
    detail 'MyText'
    error 'MyText'
    passed false
  end
end
