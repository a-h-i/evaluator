class DroptDetailFromTestSuite < ActiveRecord::Migration[5.2]
  def change
    remove_column :test_suites, :detail
  end
end
