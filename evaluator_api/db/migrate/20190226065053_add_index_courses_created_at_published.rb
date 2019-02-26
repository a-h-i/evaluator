class AddIndexCoursesCreatedAtPublished < ActiveRecord::Migration[5.2]
  def change
    add_index :courses, [:created_at, :published]
  end
end
