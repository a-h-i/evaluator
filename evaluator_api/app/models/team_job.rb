# == Schema Information
#
# Table name: team_jobs
#
#  id         :integer          not null, primary key
#  data       :binary
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_team_jobs_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#

class TeamJob < ActiveRecord::Base
  belongs_to :user
  validates :user, presence: true
  validate :data_exists

  def as_json(_options = {})
    super(only: [:id])
  end

  def send_status(status)
    event = {
      type: Rails.application.config
                 .configurations[:notification_event_types][:team_job_status],
      date: DateTime.now.utc,
      payload: {
        status: status
      }
    }
    Notifications::TeamJobsController.publish(
      "/notifications/team_jobs/#{id}",
      event
    )
  end

  def data_exists
    errors.add(:data, 'can not be blank') if data.nil? || data.size == 0
  end
end
