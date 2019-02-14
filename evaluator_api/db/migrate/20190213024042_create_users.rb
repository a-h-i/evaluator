class CreateUsers < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
    CREATE TABLE users (
      id BIGSERIAL PRIMARY KEY
      created_at timestamp without timezone not null default localtimestamp,
      updated_at timestamp without timezone not null,
      guc_prefix integer,
      guc_suffix integer, 
      password_digest text not null,
      name text not null,
      email text not null UNIQUE,
      major text,
      study_group text,
      verified boolean not null default false,
      verified_teacher boolean not null default false,
      super_user boolean not null default false,
      student boolean not null default true
    ); 
    
    SQL
  end

  def down
    drop_table :users
  end
end
