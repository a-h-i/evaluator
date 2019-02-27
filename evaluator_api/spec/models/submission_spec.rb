# == Schema Information
#
# Table name: submissions
#
#  id           :bigint(8)        not null, primary key
#  project_id   :bigint(8)        not null
#  submitter_id :bigint(8)        not null
#  course_id    :bigint(8)        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  mime_type    :text             not null
#  file_name    :text             not null
#  team         :text
#

require 'rails_helper'

RSpec.describe Submission, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
