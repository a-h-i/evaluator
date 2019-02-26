class AddIndexProjectsCourseId < ActiveRecord::Migration[5.2]
  def change
    add_index :projects, [:course_id]
  end
end
