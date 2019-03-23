class AddFileNameToTestSuites < ActiveRecord::Migration[5.2]
  def change
    add_column :test_suites, :file_name, :text, null: false
  end
end
