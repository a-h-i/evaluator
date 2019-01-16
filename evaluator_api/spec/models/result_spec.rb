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

require 'rails_helper'

RSpec.describe Result, type: :model do
  it { should belong_to :submission }
  it { should belong_to :test_suite }
  it { should belong_to :project }
  it { should validate_presence_of :submission }
  it { should validate_presence_of :test_suite }
  it { should validate_presence_of :project }
  it { should validate_presence_of :compiler_stderr }
  it { should validate_presence_of :compiler_stdout }
  it { should validate_presence_of :grade }
  it { should validate_presence_of :max_grade }
  it { should have_many :test_cases }

  it 'has a valid factory' do
    result = FactoryGirl.build(:result)
    expect(result).to be_valid
  end

  it 'validates success' do
    result = FactoryGirl.build(:result, success: nil)
    expect(result).to_not be_valid
  end

  it 'validates compiled' do
    result = FactoryGirl.build(:result, compiled: nil)
    expect(result).to_not be_valid
  end

  it 'grade can not be less than zero' do
    result = FactoryGirl.build(:result, grade: -1)
    expect(result).to_not be_valid
  end

  it 'grade can not be greater than max_grade' do
    result = FactoryGirl.build(:result, grade: 30, max_grade: 10)
    expect(result).to_not be_valid
  end

  context 'hidden' do
    it 'is set to test suite value on save' do
      result = FactoryGirl.create(:result,
                                  test_suite: FactoryGirl.create(:public_suite))
      expect(result.hidden).to be false
      result = FactoryGirl.create(:result,
                                  test_suite: FactoryGirl.create(:private_suite))
      expect(result.hidden).to be true
    end
  end
end
