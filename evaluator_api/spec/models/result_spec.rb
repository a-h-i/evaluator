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

require "rails_helper"

RSpec.describe Result, type: :model  do
  it { should belong_to :submission }
  it { should belong_to :test_suite }
  it { should belong_to :project }
  it { should validate_presence_of :submission }
  it { should validate_presence_of :test_suite }
  it { should validate_presence_of :project }
  it { should validate_presence_of :grade }
  it { should validate_presence_of :max_grade }
  it { should validate_presence_of :detail }
  it { should validate_presence_of :success }
end
