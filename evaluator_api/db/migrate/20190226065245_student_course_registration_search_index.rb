class StudentCourseRegistrationSearchIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :student_course_registrations, [:student_id, :course_id]
  end
end
