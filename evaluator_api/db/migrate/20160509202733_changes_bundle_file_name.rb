class ChangesBundleFileName < ActiveRecord::Migration[4.2]
  def change
    change_column_null :project_bundles, :file_name, true
  end
end
