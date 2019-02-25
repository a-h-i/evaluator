# == Schema Information
#
# Table name: test_suites
#
#  id         :bigint(8)        not null, primary key
#  project_id :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  timeout    :integer          default(60), not null
#  max_grade  :integer          default(0), not null
#  name       :text             not null
#  test_cases :jsonb
#  detail     :jsonb            not null
#  hidden     :boolean          default(TRUE), not null
#  ready      :boolean          default(FALSE), not null
#

require 'rails_helper'

RSpec.describe TestSuite, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
