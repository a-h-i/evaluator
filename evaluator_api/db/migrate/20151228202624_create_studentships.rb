class CreateStudentships < ActiveRecord::Migration[4.2]
  def change
    create_table :studentships do |t|
      t.references :course, index: true, foreign_key: true
      t.integer :student_id, index: true
      t.timestamps null: false
    end
    add_foreign_key :studentships, :users, column: :student_id
  end
end
