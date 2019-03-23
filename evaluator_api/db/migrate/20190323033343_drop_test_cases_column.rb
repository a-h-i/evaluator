class DropTestCasesColumn < ActiveRecord::Migration[5.2]
  def change
    remove_column :test_suites, :test_cases
    remove_column :test_suites, :ready
    remove_column :test_suites, :max_grade
  end
end
