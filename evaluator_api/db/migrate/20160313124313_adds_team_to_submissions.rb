class AddsTeamToSubmissions < ActiveRecord::Migration[4.2]
  def up
    add_column :submissions, :team, :string
    execute(
    'UPDATE submissions SET team = users.team ' \
    'FROM users ' \
    'WHERE users.id = submissions.submitter_id'
    )
    add_index :submissions, [:project_id, :team]
  end

  def down
    remove_column :submissions, :team
  end
end
