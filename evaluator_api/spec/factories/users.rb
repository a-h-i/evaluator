# == Schema Information
#
# Table name: users
#
#  id               :bigint(8)        not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  guc_prefix       :integer
#  guc_suffix       :integer
#  password_digest  :text             not null
#  name             :text             not null
#  email            :text             not null
#  major            :text
#  study_group      :text
#  verified         :boolean          default(FALSE), not null
#  verified_teacher :boolean          default(FALSE), not null
#  super_user       :boolean          default(FALSE), not null
#  student          :boolean          default(TRUE), not null
#
# Indexes
#
#  users_created_at_asc  (created_at)
#  users_email_key       (email) UNIQUE
#

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    password { Faker::Internet.password }
    verified { true }
    
    factory :student do
      email { (0...10).map { ("a".."z").to_a[rand(26)] }.join + "@student.guc.edu.eg" }
      major { Faker::Lorem.word }
      study_group { Faker::Lorem.word }
      guc_suffix { Faker::Number.number(4) }
      guc_prefix { Faker::Number.number(2) }
    end

    factory :teacher do
      email { (0...10).map { ("a".."z").to_a[rand(26)] }.join + "@guc.edu.eg" }
      verified_teacher { true }
      factory :super_user do
        super_user { true }
      end
    end
  end
end
