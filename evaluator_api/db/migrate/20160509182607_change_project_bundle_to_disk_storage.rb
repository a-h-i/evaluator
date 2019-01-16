class ChangeProjectBundleToDiskStorage < ActiveRecord::Migration[4.2]
  def change
    execute('DELETE FROM project_bundles')
    remove_column :project_bundles, :data
    add_column :project_bundles, :file_name, :string, null: false
  end
end
