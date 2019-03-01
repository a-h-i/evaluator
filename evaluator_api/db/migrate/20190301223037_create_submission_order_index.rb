class CreateSubmissionOrderIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :submissions, [:submitter_id, :project_id, :created_at]
  end
end
