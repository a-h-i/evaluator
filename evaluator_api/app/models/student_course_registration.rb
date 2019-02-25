# == Schema Information
#
# Table name: student_course_registrations
#
#  id         :bigint(8)        not null, primary key
#  course_id  :bigint(8)        not null
#  student_id :bigint(8)        not null
#  team       :text
#

class StudentCourseRegistration < ApplicationRecord
  belongs_to :course, inverse_of: :student_course_registrations
  belongs_to :student, class_name: 'User', inverse_of: :student_course_registrations
  validates :student, :course, presence: true
end
