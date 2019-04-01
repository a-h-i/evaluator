class AddsDetailToTestSuites < ActiveRecord::Migration[5.2]
  def change
    add_column :test_suites, :detail, :json, null: false
  end
end
