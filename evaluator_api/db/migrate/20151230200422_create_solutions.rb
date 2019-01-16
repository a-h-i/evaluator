class CreateSolutions < ActiveRecord::Migration[4.2]
  def change
    create_table :solutions do |t|
      t.references :submission, index: true, foreign_key: true
      t.binary :code, null: false
      t.string :file_name, null: false
      t.string :mime_type, null: false

      t.timestamps null: false
    end
  end
end
