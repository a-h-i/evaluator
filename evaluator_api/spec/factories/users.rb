# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string           not null
#  guc_prefix      :integer
#  guc_suffix      :integer
#  major           :string
#  name            :string           not null
#  password_digest :string           not null
#  student         :boolean          not null
#  super_user      :boolean          default(FALSE), not null
#  team            :string
#  verified        :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email       (email) UNIQUE
#  index_users_on_guc_prefix  (guc_prefix)
#  index_users_on_guc_suffix  (guc_suffix)
#  index_users_on_name        (name)
#  index_users_on_student     (student)
#  index_users_on_super_user  (super_user)
#  index_users_on_team        (team)
#

FactoryGirl.define do
  factory :user do
    name { Faker::Name.name }
    password { Faker::Internet.password }
    verified true

    factory :student do
      email { (0...10).map { ('a'..'z').to_a[rand(26)] }.join + '@student.guc.edu.eg' }
      major { Faker::Lorem.word }
      team { Faker::Team.name }
      guc_suffix { Faker::Number.number(4) }
      guc_prefix { Faker::Number.number(2) }
    end

    factory :teacher do
      email { (0...10).map { ('a'..'z').to_a[rand(26)] }.join + '@guc.edu.eg' }

      factory :super_user do
        super_user true
      end
    end
  end
end
