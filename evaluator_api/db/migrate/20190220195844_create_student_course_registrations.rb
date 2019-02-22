class CreateStudentCourseRegistrations < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE TABLE student_course_registrations (
        id BIGSERIAL PRIMARY KEY,
        course_id BIGSERIAL REFERENCES courses (id) ON DELETE CASCADE NOT NULL ,
        student_id BIGSERIAL REFERENCES users (id) ON DELETE CASCADE NOT NULL,
        team text,
        UNIQUE (course_id, student_id)
      );
    SQL
  end

  def down
    drop_table :student_course_registrations
  end
end
