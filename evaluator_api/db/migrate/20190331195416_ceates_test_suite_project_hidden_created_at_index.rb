class CeatesTestSuiteProjectHiddenCreatedAtIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :test_suites, [:project_id, :hidden, :created_at], order: {created_at: :desc}
  end
end
