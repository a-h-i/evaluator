# == Schema Information
#
# Table name: suite_codes
#
#  id            :integer          not null, primary key
#  code          :binary           not null
#  file_name     :string           not null
#  mime_type     :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  test_suite_id :integer
#
# Indexes
#
#  index_suite_codes_on_test_suite_id  (test_suite_id)
#
# Foreign Keys
#
#  fk_rails_...  (test_suite_id => test_suites.id) ON DELETE => cascade
#

FactoryGirl.define do
  factory :suite_code do
    code do
      path = File.join(Rails.root.join('spec/fixtures/files'),
                       'test_suites/csv_test_suite.zip')
      File.binread path
    end
    mime_type Rack::Mime.mime_type '.zip'
    file_name 'csv_test_suite.zip'
  end
end
