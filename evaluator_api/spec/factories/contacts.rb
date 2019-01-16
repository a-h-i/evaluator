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

FactoryGirl.define do
  factory :contact do
    text { Faker::Hipster.paragraph }
    title { Faker::Book.title }
    reported_at { DateTime.now.utc }
  end
end
