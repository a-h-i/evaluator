class CreateSuiteCases < ActiveRecord::Migration[4.2]
  def change
    create_table :suite_cases do |t|
      t.references :test_suite, index: true, foreign_key: true
      t.string :name, null: false
      t.integer :grade, null: false, default: 0

      t.timestamps null: false
    end
    add_index :suite_cases, :name
  end
end
