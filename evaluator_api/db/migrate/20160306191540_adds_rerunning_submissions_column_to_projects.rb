class AddsRerunningSubmissionsColumnToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :reruning_submissions, :boolean, default: false, null: false
  end
end
