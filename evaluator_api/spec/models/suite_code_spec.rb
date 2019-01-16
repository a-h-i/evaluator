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

require 'rails_helper'

RSpec.describe SuiteCode, type: :model do
  it { should belong_to :test_suite }
  it { should validate_presence_of :file_name }
  it { should validate_presence_of :mime_type }
  it { should validate_presence_of :test_suite }

  it 'validates code existance' do
    sc = SuiteCode.new
    sc.mime_type = 'application/zip'
    sc.file_name = 'none_file'
    sc.code = ''
    expect(sc).to_not be_valid
  end
end
