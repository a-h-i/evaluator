# == Schema Information
#
# Table name: reset_tokens
#
#  id         :integer          not null, primary key
#  token      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_reset_tokens_on_created_at         (created_at)
#  index_reset_tokens_on_user_id            (user_id) UNIQUE
#  index_reset_tokens_on_user_id_and_token  (user_id,token)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#

FactoryGirl.define do
  factory :reset_token do
    user { FactoryGirl.create(:student) }
    token { SecureRandom.urlsafe_base64 }
  end
end
