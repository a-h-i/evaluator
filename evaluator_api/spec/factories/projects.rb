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
#  detail               :json             not null
#
# Indexes
#
#  index_projects_on_course_id                 (course_id)
#  index_projects_on_created_at_and_published  (created_at DESC,published)
#  projects_course_id_name_key                 (course_id,name) UNIQUE
#

FactoryBot.define do
  factory :project do
    due_date { Faker::Time.forward(32, :morning) }
    start_date { Faker::Time.backward }
    name { (0...30).map { ("a".."z").to_a[rand(26)] }.join }
    course { FactoryBot.create(:course) }
    spec_type {Project::JAVA_8_SPEC_TYPE}
    spec_subtype {Project::JUNIT_4_SUB_TYPE}
    dependencies {[]}
  end
end
