class CreateSuiteCodes < ActiveRecord::Migration[4.2]
  def change
    create_table :suite_codes do |t|
      t.references :test_suite, index: true, foreign_key: true
      t.binary :code, null: false
      t.string :file_name, null: false
      t.string :mime_type, null: false
      t.timestamps null: false
    end
  end
end
