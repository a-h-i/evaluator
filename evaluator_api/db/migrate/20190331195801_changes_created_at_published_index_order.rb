class ChangesCreatedAtPublishedIndexOrder < ActiveRecord::Migration[5.2]
  def change
    remove_index :projects, [:created_at, :published]
    add_index :projects, [:published, :created_at], order: {created_at: :desc}
  end
end
