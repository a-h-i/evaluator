# == Schema Information
#
# Table name: contacts
#
#  id          :integer          not null, primary key
#  reported_at :datetime         not null
#  text        :text             not null
#  title       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer
#
# Indexes
#
#  index_contacts_on_reported_at  (reported_at)
#  index_contacts_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id) ON DELETE => nullify
#

require 'rails_helper'

RSpec.describe Contact, type: :model do
  it { should belong_to :user }
  it { should validate_presence_of :text }
  it { should validate_presence_of :title }
  it { should validate_presence_of :reported_at }

  it 'should have a valid factory' do
    expect(FactoryGirl.build(:contact)).to be_valid
  end
end
