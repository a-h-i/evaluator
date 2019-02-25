# == Schema Information
#
# Table name: courses
#
#  id          :bigint(8)        not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  name        :text             not null
#  description :text             not null
#  published   :boolean          default(FALSE), not null
#

FactoryBot.define do
  factory :course do
    name { (0...42).map { ("a".."z").to_a[rand(26)] }.join }
    description { Faker::Lorem.paragraph(3) }
  end
end
