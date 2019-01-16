class AddsSuperUserIndexToUsers < ActiveRecord::Migration[4.2]
  def change
    add_index :users, :super_user
  end
end
