class Course < ApplicationRecord
  include Cachable
  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :description, presence: true
  has_many :projects, dependent: :destroy
  # dependent deletion is performed at the database level as there are no callbacks
  has_many :students, through: :student_course_registrations, class_name: 'User'
  has_many :student_course_registrations, inverse_of: :course
  scope :published, -> { where published: true }
  
end
