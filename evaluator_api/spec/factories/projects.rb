# == Schema Information
#
# Table name: projects
#
#  id                   :integer          not null, primary key
#  due_date             :datetime         not null
#  name                 :string           not null
#  published            :boolean          default(FALSE), not null
#  quiz                 :boolean          default(FALSE), not null
#  reruning_submissions :boolean          default(FALSE), not null
#  start_date           :datetime         not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  course_id            :integer
#
# Indexes
#
#  index_projects_on_course_id   (course_id)
#  index_projects_on_due_date    (due_date)
#  index_projects_on_name        (name)
#  index_projects_on_published   (published)
#  index_projects_on_quiz        (quiz)
#  index_projects_on_start_date  (start_date)
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id) ON DELETE => cascade
#

FactoryGirl.define do
  factory :project do
    due_date { Faker::Time.forward(32, :morning) }
    name { (0...30).map { ('a'..'z').to_a[rand(26)] }.join }
    course { FactoryGirl.create(:course) }
  end
end
