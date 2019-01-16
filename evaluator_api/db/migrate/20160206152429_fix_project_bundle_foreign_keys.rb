class FixProjectBundleForeignKeys < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key 'project_bundles', 'projects'
    remove_foreign_key 'project_bundles', 'users'
    add_foreign_key 'project_bundles', 'projects', on_delete: :cascade
    add_foreign_key 'project_bundles', 'users', on_delete: :cascade
  end
end
