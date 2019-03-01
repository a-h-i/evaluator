# == Schema Information
#
# Table name: student_course_registrations
#
#  id         :bigint(8)        not null, primary key
#  course_id  :bigint(8)        not null
#  student_id :bigint(8)        not null
#  team       :text
#
# Indexes
#
#  index_student_course_registrations_on_student_id_and_course_id  (student_id,course_id)
#  student_course_registrations_course_id_student_id_key           (course_id,student_id) UNIQUE
#

FactoryBot.define do
  factory :student_course_registration do
    association :student
    association :course
  end
end
