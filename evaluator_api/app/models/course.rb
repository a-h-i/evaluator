# == Schema Information
#
# Table name: courses
#
#  id          :bigint(8)        not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  name        :text             not null
#  description :text             not null
#  published   :boolean          default(FALSE), not null
#
# Indexes
#
#  courses_name_key                           (name) UNIQUE
#  index_courses_on_created_at_and_published  (created_at,published)
#

class Course < ApplicationRecord
  include Cachable
  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :description, presence: true
  has_many :projects, dependent: :destroy
  # dependent deletion is performed at the database level as there are no callbacks
  has_many :student_course_registrations, inverse_of: :course
  has_many :students, through: :student_course_registrations, class_name: 'User'
  scope :published, -> { where published: true }
  
  def register(student, team = nil)
    if team.nil?
      students << student
    else
      StudentCourseRegistration.create(course: self, student: student, team: team)
    end

  end
  def unregister(student)
    students.delete student
  end

end
