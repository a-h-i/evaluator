# == Schema Information
#
# Table name: studentships
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  course_id  :integer
#  student_id :integer
#
# Indexes
#
#  index_studentships_on_course_id   (course_id)
#  index_studentships_on_student_id  (student_id)
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id) ON DELETE => cascade
#  fk_rails_...  (student_id => users.id) ON DELETE => cascade
#

FactoryGirl.define do
  factory :studentship do
    association :student
    association :course
  end
end
