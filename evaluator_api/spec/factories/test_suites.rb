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
#  hidden     :boolean          default(TRUE), not null
#  file_name  :text             not null
#  mime_type  :text             not null
#  detail     :json             not null
#
# Indexes
#
#  index_test_suites_on_project_id_and_hidden_and_created_at  (project_id,hidden,created_at DESC)
#  test_suites_project_id_name_key                            (project_id,name) UNIQUE
#

FactoryBot.define do
  factory :test_suite do
    project do
      FactoryBot.create(:project, published: true,
        course: FactoryBot.create(:course, published: true))
    end
    file do
      path = File.join(Rails.root.join("spec/fixtures/files"),
                       "test_suites/M1PrivateTest.zip")
      File.open(path, "rb")
    end
    name {(0...30).map { ("a".."z").to_a[rand(26)] }.join}
    detail do
      {package_name: 'public'}
    end
  end
end
