# == Schema Information
#
# Table name: projects
#
#  id                   :bigint(8)        not null, primary key
#  course_id            :bigint(8)        not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  due_date             :datetime         not null
#  start_date           :datetime         not null
#  name                 :text             not null
#  published            :boolean          default(FALSE), not null
#  quiz                 :boolean          default(FALSE), not null
#  reruning_submissions :boolean          default(FALSE), not null
#

FactoryBot.define do
  factory :project do
    due_date { Faker::Time.forward(32, :morning) }
    start_date { Faker::Time.backward }
    name { (0...30).map { ("a".."z").to_a[rand(26)] }.join }
    course { FactoryBot.create(:course) }
  end
end
