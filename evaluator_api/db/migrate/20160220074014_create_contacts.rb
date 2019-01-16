class CreateContacts < ActiveRecord::Migration[4.2]
  def change
    create_table :contacts do |t|
      t.references :user, index: true
      t.text :text, null: false
      t.string :title, null: false
      t.datetime :reported_at, null: false
      t.timestamps null: false
    end
    add_index :contacts, :reported_at
    add_foreign_key :contacts, :users, on_delete: :nullify
  end
end
