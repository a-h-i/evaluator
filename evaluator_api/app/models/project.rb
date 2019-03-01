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
# Indexes
#
#  index_projects_on_course_id                 (course_id)
#  index_projects_on_created_at_and_published  (created_at DESC,published)
#  projects_course_id_name_key                 (course_id,name) UNIQUE
#

class Project < ApplicationRecord
  include Cachable
  has_many :submissions, dependent: :destroy
  has_many :test_suites, dependent: :destroy
  belongs_to :course
  scope :published, -> { where published: true }
  scope :not_published, -> { where published: false }
  scope :due, -> { where "due_date <= ?", DateTime.now }
  scope :not_due, -> { where "due_date > ?", DateTime.now }
  scope :started, -> { where "start_date <= ?", DateTime.now }
  validates :name, :due_date, :course, presence: true
  validates :name, uniqueness: { case_sensitive: false, scope: :course_id }

  def viewable_by_user?(user)
    user.teacher? || (published && StudentCourseRegistration.exists?(student_id: user.id, course_id: course_id))
  end

  def can_submit?
    due_date.utc > DateTime.now.utc && start_date.utc <= DateTime.now.utc
  end

  
end
