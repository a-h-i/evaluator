# == Schema Information
#
# Table name: test_suites
#
#  id         :integer          not null, primary key
#  hidden     :boolean          default(TRUE), not null
#  max_grade  :integer          default(0), not null
#  name       :string           not null
#  ready      :boolean          default(FALSE), not null
#  timeout    :integer          default(60), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :integer
#
# Indexes
#
#  index_test_suites_on_hidden      (hidden)
#  index_test_suites_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id) ON DELETE => cascade
#

FactoryGirl.define do
  factory :test_suite do
    project { FactoryGirl.create(:project, published: true, course: FactoryGirl.create(:course, published: true)) }
    name 'csv_test_suite'
    factory :public_suite do
      hidden false
    end
    factory :private_suite do
      hidden true
    end
  end
end
