class CreateSubmissions < ActiveRecord::Migration[4.2]
  def change
    create_table :submissions do |t|
      t.references :project, index: true, foreign_key: true
      t.integer :submitter_id, index: true, null: false
      t.timestamps null: false
    end
    add_foreign_key :submissions, :users, column: :submitter_id
  end
end
