# == Schema Information
#
# Table name: team_jobs
#
#  id         :integer          not null, primary key
#  data       :binary
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_team_jobs_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#

require 'rails_helper'

RSpec.describe TeamJob, type: :model do
  it { should belong_to :user }
  it { should validate_presence_of :user }

  it 'has a valid factory' do
    team_job = FactoryGirl.build(:team_job)
    expect(team_job).to be_valid
  end
  
  it 'validates data existance' do
    team_job = FactoryGirl.build(:team_job)
    team_job.data = ''
    expect(team_job).to_not be_valid
  end
end
