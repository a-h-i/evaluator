class AddDefaultToResultsUpdatedAt < ActiveRecord::Migration[5.2]
  def change
    change_column :results, :updated_at, :timestamp , default: -> {'localtimestamp'}
  end
end
