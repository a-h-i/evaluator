class AddMimeTypeToTestSuite < ActiveRecord::Migration[5.2]
  def change
    add_column :test_suites, :mime_type, :text, null: false
  end
end
