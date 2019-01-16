class AddsSuperUserToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :super_user, :boolean, null: false, default: false
  end
end
