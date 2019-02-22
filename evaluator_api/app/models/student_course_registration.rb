class StudentCourseRegistration < ApplicationRecord
  belongs_to :course, inverse_of: :student_course_registrations
  belongs_to :student, class_name: 'User', inverse_of: :student_course_registrations
  validates :student, :course, presence: true
end
