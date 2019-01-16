require 'csv'
class TeamAssignmentJob < ActiveJob::Base
  queue_as :default

  def perform(team_job)
    data = CSV.parse team_job.data
    data = data[1..-1]
    status = {
      total_rows: data.size,
      processed: 0,
      messages: []
    }
    team_job.send_status status
    data.each do |row|
      guc_id = row.first.strip
      destination_team = row.second.strip
      user = User.find_by_guc_id(guc_id)
      if !user.nil?
        user.team = destination_team
        unless user.save
          status[:messages] << "Could not set team #{destination_team} for user with GUC ID #{guc_id}"
        end
      else
        status[:messages] << "Could not find user with GUC ID #{guc_id}."
      end
      status[:processed] += 1
      team_job.send_status status
    end
  end
end
