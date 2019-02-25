# == Schema Information
#
# Table name: submissions
#
#  id           :bigint(8)        not null, primary key
#  project_id   :bigint(8)        not null
#  submitter_id :bigint(8)        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  team         :text
#

FactoryBot.define do
  factory :submission do
    
  end
end
