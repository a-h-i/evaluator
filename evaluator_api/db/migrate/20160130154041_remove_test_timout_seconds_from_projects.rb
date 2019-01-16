class RemoveTestTimoutSecondsFromProjects < ActiveRecord::Migration[4.2]
  def change
    remove_column :projects, :test_timeout_seconds, :integer
  end
end
