# == Schema Information
#
# Table name: projects
#
#  id                   :integer          not null, primary key
#  due_date             :datetime         not null
#  name                 :string           not null
#  published            :boolean          default(FALSE), not null
#  quiz                 :boolean          default(FALSE), not null
#  reruning_submissions :boolean          default(FALSE), not null
#  start_date           :datetime         not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  course_id            :integer
#
# Indexes
#
#  index_projects_on_course_id   (course_id)
#  index_projects_on_due_date    (due_date)
#  index_projects_on_name        (name)
#  index_projects_on_published   (published)
#  index_projects_on_quiz        (quiz)
#  index_projects_on_start_date  (start_date)
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id) ON DELETE => cascade
#

class Project < ActiveRecord::Base
  include Cacheable
  belongs_to :course, inverse_of: :projects
  has_many :submissions, inverse_of: :project, dependent: :destroy
  has_many :test_suites, inverse_of: :project, dependent: :destroy
  # Resuts and team grades destroyed by submissions
  has_many :results, inverse_of: :project, dependent: :destroy
  before_validation :default_start_date
  validates :name, :due_date, :course, presence: true
  validate :unique_name_per_course
  before_save :due_date_to_utc, :start_date_to_utc
  before_save :due_start_dates_times
  after_save :rerun_submissions_check
  scope :published, -> { where published: true }
  scope :not_published, -> { where published: false }
  scope :due, ->  { where 'due_date <= ?', DateTime.now.utc }
  scope :not_due, -> { where 'due_date > ?', DateTime.now.utc }
  scope :started, -> { where 'start_date <= ?', DateTime.now.utc }
  after_create :send_created_notification
  before_save :send_published_notification
  after_destroy :send_deleted_notification

  def send_created_notification
    event = {
      type: Rails.application.config.configurations[:notification_event_types][:project_created],
      date: DateTime.now.utc,
      payload: {
        project: as_json
      }
    }
    Notifications::CoursesController.publish(
      "/notifications/courses/#{course.id}",
      event
    )
  end

  def notify_bundle_ready(project_bundle)
    event = {
      type: Rails.application.config.configurations[:notification_event_types][:project_bundle_ready],
      date: DateTime.now.utc,
      payload: {
        bundle: project_bundle.as_json
      }
    }
    Notifications::ProjectsController.publish(
      "/notifications/projects/#{id}",
      event
    )
  end

  def send_published_notification
    if published_changed?
      types = Rails.application.config.configurations[:notification_event_types]
      type = if published?
               types[:project_published]
             else
               types[:project_unpublished]
             end
      event = {
        type: type,
        date: DateTime.now.utc,
        payload: {
          project: as_json
        }
      }
      Notifications::CoursesController.publish(
        "/notifications/courses/#{course.id}",
        event
      )
      Notifications::ProjectsController.publish(
        "/notifications/projects/#{id}",
        event
      )
    end
  end

  def send_deleted_notification
    event = {
      type: Rails.application.config.configurations[:notification_event_types][:project_deleted],
      date: DateTime.now.utc
    }
    Notifications::ProjectsController.publish(
      "/notifications/projects/#{id}",
      event
    )
  end

  def can_submit?
    due_date.utc > DateTime.now.utc && start_date.utc <= DateTime.now.utc
  end

  private

  def rerun_submissions_check
    if reruning_submissions_changed? && reruning_submissions?
      RerunSubmissionsJob.perform_later(self)
    end
  end

  def unique_name_per_course
    if !course.nil? && !name.nil? && !persisted?
      if Project.where(course: course, name: name).count != 0
        errors.add(:name, 'must be unique per course')
      end
    end
  end

  def due_start_dates_times
    unless persisted?
      self.due_date = due_date.utc.change(hour: 21, min: 59)
      self.start_date = start_date.utc.change(hour: 0, min: 0)
    end
  end

  def due_date_to_utc
    self.due_date = due_date.utc
  end

  def default_start_date
    self.start_date = DateTime.now if start_date.nil?
  end

  def start_date_to_utc
    self.start_date = start_date.utc
  end
end
