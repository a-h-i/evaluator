class CreatedSubmissionTeamIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :submissions, :team
  end
end
