class AddsSubmissionIdToTeamGrade < ActiveRecord::Migration[4.2]
  def up
    add_column :team_grades, :submission_id, :integer
    execute(
    'UPDATE team_grades SET submission_id = results.submission_id ' \
    'FROM results ' \
    ' WHERE results.id = team_grades.result_id '
    )
    add_foreign_key :team_grades, :submissions, on_delete: :cascade
    add_index :team_grades, [:submission_id, :project_id]
    change_column_null :team_grades, :submission_id, false
  end
  def down
    remove_column :team_grades, :submission_id
  end
end
