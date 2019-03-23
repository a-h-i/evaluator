# == Schema Information
#
# Table name: test_suites
#
#  id         :bigint(8)        not null, primary key
#  project_id :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  timeout    :integer          default(60), not null
#  name       :text             not null
#  detail     :jsonb            not null
#  hidden     :boolean          default(TRUE), not null
#  file_name  :text             not null
#
# Indexes
#
#  test_suites_project_id_name_key  (project_id,name) UNIQUE
#

FactoryBot.define do
  factory :test_suite do
    
  end
end
