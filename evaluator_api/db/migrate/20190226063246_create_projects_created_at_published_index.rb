class CreateProjectsCreatedAtPublishedIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :projects, [:created_at, :published], order: {created_at: :desc}
  end
end
