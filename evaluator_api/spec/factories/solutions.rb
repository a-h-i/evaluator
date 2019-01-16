# == Schema Information
#
# Table name: solutions
#
#  id            :integer          not null, primary key
#  code          :binary           not null
#  file_name     :string           not null
#  mime_type     :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  submission_id :integer
#
# Indexes
#
#  index_solutions_on_submission_id  (submission_id)
#
# Foreign Keys
#
#  fk_rails_...  (submission_id => submissions.id) ON DELETE => cascade
#

FactoryGirl.define do
  factory :solution do
    code do
      path = File.join(Rails.root.join('spec/fixtures/files'),
                       'submissions/csv_submission.zip')
      File.binread path
    end
    mime_type Rack::Mime.mime_type '.zip'
    file_name 'csv_submission.zip'
  end
end
