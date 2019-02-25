# == Schema Information
#
# Table name: student_course_registrations
#
#  id         :bigint(8)        not null, primary key
#  course_id  :bigint(8)        not null
#  student_id :bigint(8)        not null
#  team       :text
#

FactoryBot.define do
  factory :student_course_registration do
    association :student
    association :course
  end
end
