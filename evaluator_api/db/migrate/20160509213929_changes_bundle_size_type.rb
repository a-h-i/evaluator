class ChangesBundleSizeType < ActiveRecord::Migration[4.2]
  def change
    change_column :project_bundles, :size_bytes, :bigint
  end
end
