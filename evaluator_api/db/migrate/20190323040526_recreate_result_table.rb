class RecreateResultTable < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
    DROP TABLE results;
    CREATE TABLE results (
      id BIGSERIAL PRIMARY KEY,
      submission_id BIGSERIAL REFERENCES submissions (id) ON DELETE CASCADE NOT NULL,
      project_id BIGSERIAL REFERENCES projects (id) ON DELETE CASCADE NOT NULL,
      test_suite_id BIGSERIAL REFERENCES test_suites (id) ON DELETE CASCADE NOT NULL,
      submitter_id BIGSERIAL REFERENCES users (id) ON DELETE CASCADE NOT NULL,
      team TEXT,
      created_at timestamp without time zone not null default localtimestamp,
      updated_at timestamp without time zone not null,
      max_grade integer NOT NULL,
      grade integer NOT NULL,
      success boolean NOT NULL,
      hidden boolean NOT NULL,
      detail jsonb NOT NULL
    );
    SQL
  end

  def down
    drop_table :results
    execute <<-SQL
    CREATE TABLE results (
      id BIGSERIAL PRIMARY KEY,
      submission_id BIGSERIAL REFERENCES submissions (id) ON DELETE CASCADE NOT NULL,
      project_id BIGSERIAL REFERENCES projects (id) ON DELETE CASCADE NOT NULL,
      test_suite_id BIGSERIAL REFERENCES test_suites (id) ON DELETE CASCADE NOT NULL,
      created_at timestamp without time zone not null default localtimestamp,
      updated_at timestamp without time zone not null,
      max_grade integer NOT NULL,
      grade integer NOT NULL,
      success boolean NOT NULL,
      hidden boolean NOT NULL,
      detail jsonb NOT NULL
    );
    SQL
  end
end
