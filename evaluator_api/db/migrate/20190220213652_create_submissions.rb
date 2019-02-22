class CreateSubmissions < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
    CREATE TABLE submissions(
      id BIGSERIAL PRIMARY KEY,
      project_id BIGSERIAL REFERENCES projects (id) NOT NULL,
      submitter_id BIGSERIAL REFERENCES users (id) NOT NULL,
      created_at timestamp without time zone NOT NULL default localtimestamp,
      updated_at timestamp without time zone NOT NULL,
      team text
    );
    SQL
  end

  def down
    drop_table :submissions
  end
end
