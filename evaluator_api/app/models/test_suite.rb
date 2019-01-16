# == Schema Information
#
# Table name: test_suites
#
#  id         :integer          not null, primary key
#  hidden     :boolean          default(TRUE), not null
#  max_grade  :integer          default(0), not null
#  name       :string           not null
#  ready      :boolean          default(FALSE), not null
#  timeout    :integer          default(60), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :integer
#
# Indexes
#
#  index_test_suites_on_hidden      (hidden)
#  index_test_suites_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id) ON DELETE => cascade
#

class TestSuite < ActiveRecord::Base
  belongs_to :project, inverse_of: :test_suites
  has_one :suite_code, dependent: :delete
  has_many :suite_cases, dependent: :delete_all
  has_many :results, dependent: :destroy
  validates :name, presence: true
  after_destroy :send_deleted_notification
  after_create :send_created_notification

  def as_json(_options = {})
    super(include: [:suite_cases])
  end

  def send_processed_notification
    event = {
      type: Rails.application.config.configurations[:notification_event_types][:test_suite_processed],
      date: DateTime.now.utc,
      payload: {
        test_suite: as_json
      }
    }
    Notifications::TestSuitesController.publish(
      "/notifications/test_suites/#{id}",
      event
    )
  end

  def send_deleted_notification
    event = {
      type: Rails.application.config.configurations[:notification_event_types][:suite_deleted],
      date: DateTime.now.utc
    }
    Notifications::TestSuitesController.publish(
      "/notifications/test_suites/#{id}",
      event
    )
  end

  def send_created_notification
    event = {
      type: Rails.application.config.configurations[:notification_event_types][:suite_created],
      date: DateTime.now.utc,
      payload: {
        test_suite: as_json
      }
    }
    Notifications::ProjectsController.publish(
      "/notifications/projects/#{project.id}",
      event
    )
  end

  def self.viewable_by_user(_user)
    self
  end

  def destroyable?
    !project.published? && ready?
  end
end
