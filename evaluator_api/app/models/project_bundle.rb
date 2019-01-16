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

class ProjectBundle < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  validates :user, :project, presence: :true
  validate :user_teacher
  after_destroy :remove_file

  def as_json(_options = {})
    super(except: [:file_name],
          methods: [:ready, :project_name]
      )
  end

  def ready
    file_name.present?
  end

  def project_name
    project.name
  end

  def filename
    "#{created_at}-#{project.name}-#{user.name}.tar.gz"
  end

  private

  def remove_file
    if file_name.present?
      File.delete(file_name)
    end
  end

  def user_teacher
    errors.add(:user, 'must be teacher') if !user.nil? && user.student
  end
end
