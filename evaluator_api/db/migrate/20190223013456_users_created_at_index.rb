class UsersCreatedAtIndex < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
    CREATE INDEX users_created_at_asc ON users (created_at ASC);
    SQL
  end

  def down
    execute <<-SQL
    DROP INDEX users_created_at_asc;
    SQL
  end
end
