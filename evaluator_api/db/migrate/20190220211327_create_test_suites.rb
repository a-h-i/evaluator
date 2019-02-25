class CreateTestSuites < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
    CREATE TABLE test_suites(
      id BIGSERIAL PRIMARY KEY,
      project_id BIGSERIAL REFERENCES projects (id) NOT NULL,
      created_at timestamp without time zone NOT NULL default localtimestamp,
      updated_at timestamp without time zone NOT NULL,
      timeout integer NOT NULL DEFAULT 60,
      max_grade integer NOT NULL DEFAULT 0,
      name text NOT NULL,
      test_cases jsonb,
      detail jsonb NOT NULL,
      hidden boolean NOT NULL DEFAULT true,
      ready boolean NOT NULL DEFAULT false,
      UNIQUE(project_id, name)
    );
    SQL
  end

  def down
    drop_table :test_suites
  end
end
