class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :password_digest, null: false
      t.string :email, null: false
      t.boolean :student, null: false
      t.boolean :verified, default: false, null: false
      t.string :major
      t.string :team
      t.integer :guc_suffix
      t.integer :guc_prefix
      t.timestamps null: false
    end
    add_index :users, :name
    add_index :users, :email, unique: true
    add_index :users, :student
    add_index :users, :team
    add_index :users, :guc_suffix
    add_index :users, :guc_prefix
  end
end
