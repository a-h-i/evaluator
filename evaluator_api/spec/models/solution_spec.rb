# == Schema Information
#
# Table name: solutions
#
#  id            :integer          not null, primary key
#  code          :binary           not null
#  file_name     :string           not null
#  mime_type     :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  submission_id :integer
#
# Indexes
#
#  index_solutions_on_submission_id  (submission_id)
#
# Foreign Keys
#
#  fk_rails_...  (submission_id => submissions.id) ON DELETE => cascade
#

require 'rails_helper'

RSpec.describe Solution, type: :model do
  it { should belong_to :submission }
  it { should validate_presence_of :file_name }
  it { should validate_presence_of :mime_type }
  it { should validate_presence_of :submission }

  it 'has a valid factory' do
    submission = FactoryGirl.create(:submission)
    solution = FactoryGirl.build(:solution, submission: submission)
    expect(solution).to be_valid
  end
end
