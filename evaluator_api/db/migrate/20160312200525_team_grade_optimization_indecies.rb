class TeamGradeOptimizationIndecies < ActiveRecord::Migration[4.2]
  def change
    add_index :team_grades, [:submission_created_at, :project_id, :name], name: 'per_team_optimization'
  end
end
