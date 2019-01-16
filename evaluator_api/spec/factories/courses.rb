# == Schema Information
#
# Table name: courses
#
#  id          :integer          not null, primary key
#  description :text             not null
#  name        :string           not null
#  published   :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_courses_on_name       (name) UNIQUE
#  index_courses_on_published  (published)
#

FactoryGirl.define do
  factory :course do
    name { (0...42).map { ('a'..'z').to_a[rand(26)] }.join }
    description { Faker::Lorem.paragraph(3) }
  end
end
