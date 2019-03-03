class ResultsSubmissionIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :results, :submission_id
  end
end
