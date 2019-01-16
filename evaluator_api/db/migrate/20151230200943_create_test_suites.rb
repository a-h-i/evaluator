class CreateTestSuites < ActiveRecord::Migration[4.2]
  def change
    create_table :test_suites do |t|
      t.references :project, index: true, foreign_key: true
      t.boolean :hidden, index: true, null: false, default: true
      t.boolean :ready, null: false, default: false
      t.integer :max_grade, null: false, default: 0
      t.integer :timeout, null: false, default: 60
      t.string :name, null: false
      t.timestamps null: false
    end
  end
end
