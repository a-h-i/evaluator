# == Schema Information
#
# Table name: project_bundles
#
#  id         :integer          not null, primary key
#  file_name  :string
#  size_bytes :bigint(8)        default(0), not null
#  teams_only :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :integer
#  user_id    :integer
#
# Indexes
#
#  index_project_bundles_on_project_id  (project_id)
#  index_project_bundles_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id) ON DELETE => cascade
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#

require 'rails_helper'

RSpec.describe ProjectBundle, type: :model do
  it { should validate_presence_of :user }
  it { should validate_presence_of :project }
  it { should belong_to :user }
  it { should belong_to :project }

  it 'user must be teacher' do
    bundle = FactoryGirl.build(:project_bundle, user: FactoryGirl.create(:student))
    expect(bundle).to_not be_valid
  end

  it 'has a valid factory' do
    bundle = FactoryGirl.build(:project_bundle)
    expect(bundle).to be_valid
  end
end
