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

class VerificationToken < ActiveRecord::Base
  belongs_to :user
  validates :user, presence: true, uniqueness: true
  validates :token, presence: true
end
