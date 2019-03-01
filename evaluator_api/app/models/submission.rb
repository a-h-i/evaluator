# == Schema Information
#
# Table name: submissions
#
#  id           :bigint(8)        not null, primary key
#  project_id   :bigint(8)        not null
#  submitter_id :bigint(8)        not null
#  course_id    :bigint(8)        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  mime_type    :text             not null
#  file_name    :text             not null
#  team         :text
#

class Submission < ApplicationRecord
  include FileSanitizer
  include FileAttachable
  belongs_to :project
  belongs_to :submitter, class_name: "User", inverse_of: :submissions
  belongs_to :course
  before_validation :set_values
  before_validation {self.file_name = self.class.sanitize_file_name(self.file_name) unless self.file_name.nil?}
  validates :project, :submitter, presence: true
  validate :published_project_and_course
  validate :project_can_submit
  
  def file=(val)
    self.file_attachable_storage_file_object = val
    self.file_name = if val.respond_to? :original_filename
       val.original_filename
    elsif val.respond_to? :filename
      val.filename
    else
      File.basename(val.path)
    end
      self.mime_type =  if val.respond_to? :content_type
      val.content_type
    else
      'application/binary'
    end
    file
  end

  def file
    :file_attachable_storage_file_object
  end

  def evaluate
    MessagingService.queue_submission_eval_job(self)
  end

  def cull
    MessagingService.queue_submission_cul_job(submitter, project) if Submission.where(submitter: @current_user,
      project: @project).count > Rails.application.config.configurations[:max_num_submissions]
  end

  def self.viewable_by_user(user)
    if user.student?
      user.submissions
    else
      self
    end
  end
  def file_path
    @file_path_internal ||= get_file_path(file_name)
  end
  def get_file_path(file_name)
    timestamp = created_at.strftime('%Y_%j_%H_%M_%S_%L')
    ext = File.extname(file_name).empty? ? ".zip" : File.extname(file_name)
    File.join Rails.application.config.submissions_path,  "#{id}_#{timestamp}#{ext}"
  end

  def is_viewable_by?(user)
    user.teacher? || user.id == submitter_id
  end

  private

  def set_values
    set_course
    set_team
  end

  def set_team
    self.team = StudentCourseRegistration.where(student_id: submitter_id, course_id: course_id).pluck(:team).first if submitter.present? && project.present?
  end

  def set_course
    self.course = project.course unless project.nil?
  end

  def project_can_submit
    errors.add(:project, 'Must be before deadline and after start date') unless
      project.nil? || project.can_submit?
  end

  def published_project_and_course
    unless project.nil?
      if course.nil? || !project.published? || !course.published?
        errors.add(:project, 'Must be published and belong to a published course')
      end
    end
  end
end
