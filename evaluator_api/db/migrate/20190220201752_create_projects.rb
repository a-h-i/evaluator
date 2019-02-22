class CreateProjects < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE TABLE projects (
        id BIGSERIAL PRIMARY KEY,
        course_id BIGSERIAL REFERENCES courses (id) NOT NULL,
        created_at timestamp without time zone not null default localtimestamp,
        updated_at timestamp without time zone not null,
        due_date timestamp with time zone not null,
        start_date timestamp with time zone not null,
        name text not null,
        published boolean not null default false,
        quiz boolean not null default false,
        reruning_submissions boolean not null default false,
        UNIQUE (course_id, name)
      );
    SQL
  end

  def down
    drop_table :projects
  end
end
