FactoryBot.define do
  factory :course do
    name { (0...42).map { ("a".."z").to_a[rand(26)] }.join }
    description { Faker::Lorem.paragraph(3) }
  end
end
