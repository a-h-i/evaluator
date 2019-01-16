class AddsTeamAndSizeToProjectBundle < ActiveRecord::Migration[4.2]
  def change
    add_column :project_bundles, :teams_only, :boolean, default: false, null: false
    add_column :project_bundles, :size_bytes, :integer, default: 0, null: false
  end
end
