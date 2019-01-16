class CreateResults < ActiveRecord::Migration[4.2]
  def change
    create_table :results do |t|
      t.references :submission, index: true, foreign_key: true
      t.references :test_suite, index: true, foreign_key: true
      t.references :project, index: true, foreign_key: true
      t.boolean :compiled, null: false
      t.text :compiler_stderr, null: false
      t.text :compiler_stdout, null: false
      t.integer :grade, null: false
      t.integer :max_grade, null: false
      t.boolean :hidden, null: false
      t.boolean :success, null: false
      t.timestamps null: false
    end
  end
end
