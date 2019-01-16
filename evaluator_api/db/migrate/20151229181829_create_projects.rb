class CreateProjects < ActiveRecord::Migration[4.2]
  def change
    create_table :projects do |t|
      t.datetime :due_date, null: false
      t.datetime :start_date, null: false
      t.string :name, null: false
      t.references :course, index: true, foreign_key: true
      t.integer :test_timeout_seconds, null: false, default: 600
      t.boolean :quiz, default: false, null: false
      t.boolean :published, default: false, null: false
      t.timestamps null: false
    end
    add_index :projects, :name
    add_index :projects, :quiz
    add_index :projects, :published
    add_index :projects, :due_date
    add_index :projects, :start_date
  end
end
