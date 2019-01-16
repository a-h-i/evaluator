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

FactoryGirl.define do
  factory :team_job do
    user { FactoryGirl.create(:teacher, verified: true) }
    data do
      path = File.join(Rails.root.join('spec/fixtures/files'),
                       'teams/teams_example.csv')
      File.binread path
    end
  end
end
