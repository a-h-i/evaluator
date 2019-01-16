class AddsSubmissionCreatedAtToTeamGrades < ActiveRecord::Migration[4.2]
  def up
    add_column :team_grades, :submission_created_at, :datetime
    execute(
    'UPDATE team_grades SET submission_created_at = submissions.created_at ' \
    'FROM submissions ' \
    'WHERE submissions.id = team_grades.submission_id'
    )
    change_column_null :team_grades, :submission_created_at, false
    add_index :team_grades, :submission_created_at
  end

  def down
    remove_column :team_grades, :submission_created_at
  end
end
