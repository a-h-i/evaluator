# == Schema Information
#
# Table name: submissions
#
#  id           :integer          not null, primary key
#  team         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  project_id   :integer
#  submitter_id :integer          not null
#
# Indexes
#
#  index_submissions_on_created_at           (created_at)
#  index_submissions_on_project_id           (project_id)
#  index_submissions_on_project_id_and_team  (project_id,team)
#  index_submissions_on_submitter_id         (submitter_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id) ON DELETE => cascade
#  fk_rails_...  (submitter_id => users.id) ON DELETE => cascade
#

class Submission < ActiveRecord::Base
  include Cacheable
  belongs_to :project
  belongs_to :submitter, class_name: 'User', inverse_of: :submissions
  has_one :solution, dependent: :delete
  validates :project, :submitter, presence: true
  has_many :results, dependent: :destroy
  before_validation :set_team
  validate :published_project_and_course
  validate :project_can_submit
  after_destroy :send_deleted_notification

  def as_json(_options = {})
    super(except: [:solution_id])
      .merge(submitter: submitter.as_json,
             num_suites: project.test_suites.count,
             results: results.as_json)
  end

  def send_new_result_notification(result)
    event = {
      type: Rails.application.config.configurations[:notification_event_types][:submission_result_ready],
      date: DateTime.now.utc,
      payload: {
        result: result.as_json
      }
    }
    Notifications::SubmissionsController.publish(
      "/notifications/submissions/#{id}",
      event
    )
  end

  def send_new_team_grade_notification
    return if submitter.team.nil?
    event = {
      type: Rails.application.config.configurations[:notification_event_types][:team_grade_created],
      date: DateTime.now.utc,
      payload: {
        submission: as_json
      }
    }
    Notifications::TeamsController.publish(
      "/notifications/teams/#{team.gsub(' ', '_')}",
      event
    )
  end

  def send_deleted_notification
    event = {
      type: Rails.application.config.configurations[:notification_event_types][:submission_deleted],
      date: DateTime.now.utc
    }
    Notifications::SubmissionsController.publish(
      "/notifications/submissions/#{id}",
      event
    )
  end

  def self.viewable_by_user(user)
    if user.student?
      user.submissions
    else
      self
    end
  end

  def self.newest_per_submitter_of_project(project)
    project.submissions.where(
      'NOT EXISTS ( ' \
      'SELECT 1 FROM submissions AS other ' \
      'WHERE other.submitter_id = submissions.submitter_id ' \
      'AND other.created_at > submissions.created_at ' \
      "AND other.project_id = #{project.id}" \
      ')'
    )
  end

  def self.without_results_of_project(project)
    find_by_sql(
      [
        'SELECT submissions.* FROM submissions ' \
        'WHERE submissions.project_id = ? ' \
        'AND NOT EXISTS ( ' \
        'SELECT 1 FROM results WHERE results.project_id = ? ' \
        'AND results.submission_id = submissions.id )',
        project.id, project.id
      ]
    )
  end

  def self.newest_per_team_of_project(project)
    find_by_sql(
      [
        'SELECT submissions.* FROM submissions ' \
        'WHERE submissions.project_id = ? ' \
        'AND submissions.team IS NOT NULL ' \
        'AND NOT EXISTS ( ' \
        'SELECT 1 FROM submissions AS other '\
        ' WHERE other.project_id = ? AND other.team = submissions.team ' \
        'AND other.created_at > submissions.created_at )',
        project.id, project.id
      ]
    )
  end

  private

  def set_team
    self.team = submitter.team if submitter.present?
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
