class CreateCourses < ActiveRecord::Migration[4.2]
  def change
    create_table :courses do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.boolean :published, default: false, null: false
      t.timestamps null: false
    end
    add_index :courses, :name, unique: true
    add_index :courses, :published
  end
end
