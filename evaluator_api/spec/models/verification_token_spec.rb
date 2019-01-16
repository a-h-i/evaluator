# == Schema Information
#
# Table name: verification_tokens
#
#  id         :integer          not null, primary key
#  token      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_verification_tokens_on_created_at         (created_at)
#  index_verification_tokens_on_user_id            (user_id) UNIQUE
#  index_verification_tokens_on_user_id_and_token  (user_id,token)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#

require 'rails_helper'

RSpec.describe VerificationToken, type: :model do
  let(:subject) { FactoryGirl.create(:verification_token) }
  it { should belong_to :user }
  it { should validate_presence_of :user }
  it { should validate_presence_of :token }
  it { should validate_uniqueness_of :user }
  
  it 'has a valid factory' do
    token = FactoryGirl.build(:verification_token)
    expect(token).to be_valid
  end
  it 'requires token' do
    token = FactoryGirl.build(:verification_token, token: nil)
    expect(token).to_not be_valid
  end
  it 'requires user' do
    token = FactoryGirl.build(:verification_token, user: nil)
    expect(token).to_not be_valid
  end
end
