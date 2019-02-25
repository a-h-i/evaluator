# == Schema Information
#
# Table name: submissions
#
#  id           :bigint(8)        not null, primary key
#  project_id   :bigint(8)        not null
#  submitter_id :bigint(8)        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  team         :text
#

class Submission < ApplicationRecord
  belongs_to :project
  belongs_to :submitter, class_name: "User", inverse_of: :submissions
  before_validation :set_team
  validates :project, :submitter, presence: true
  validate :published_project_and_course
  validate :project_can_submit

  private

  def set_team
    self.team = StudentCourseRegistration.where(student: submitter, course: project.course_id).pluck(:team) if submitter.present? && project.present?
  end

  def project_can_submit
    errors.add(:project, 'Must be before deadline and after start date') unless
      project.nil? || project.can_submit?
  end

  def published_project_and_course
    unless project.nil?
      if project.course.nil? || !project.published? || !project.course.published?
        errors.add(:project, 'Must be published and belong to a published course')
      end
    end
  end
end
