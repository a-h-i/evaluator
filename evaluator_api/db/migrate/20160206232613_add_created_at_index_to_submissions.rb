class AddCreatedAtIndexToSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_index 'submissions', ['created_at']
  end
end
