class CreateCourses < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE TABLE courses (
        id BIGSERIAL PRIMARY KEY,
        created_at timestamp without time zone not null default localtimestamp,
        updated_at timestamp without time zone not null,
        name text not null UNIQUE,
        description text not null,
        published boolean not null default false
      );
    SQL
  end

  def down
    drop_table :courses
  end
end
