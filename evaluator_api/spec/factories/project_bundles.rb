# == Schema Information
#
# Table name: project_bundles
#
#  id         :integer          not null, primary key
#  file_name  :string
#  size_bytes :bigint(8)        default(0), not null
#  teams_only :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :integer
#  user_id    :integer
#
# Indexes
#
#  index_project_bundles_on_project_id  (project_id)
#  index_project_bundles_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id) ON DELETE => cascade
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#

FactoryGirl.define do
  factory :project_bundle do
    project
    file_name do
      path = File.join(Rails.root.join('spec/fixtures/files'),
                       'submissions/bundle.tar.gz')
      new_path = Rails.root.join('tmp', "#{DateTime.now.utc}.tar.gz")
      FileUtils.cp(path, new_path)
      new_path
    end
    association :user, factory: :teacher
  end
end
