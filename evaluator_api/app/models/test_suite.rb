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

class TestSuite < ApplicationRecord
  include FileSanitizer
  include FileAttachable
  belongs_to :project
  # results are destroyed on the db level
  has_many :results
  validates :name, :project, presence: true
  validates :name, uniqueness: { case_sensitive: false, scope: :project_id }
  validates :detail, presence: true
  before_validation {self.file_name = self.class.sanitize_file_name(self.file_name) unless self.file_name.nil?}
  
  def file_path
    @file_path_internal ||= get_file_path(file_name)
  end
  
  def get_file_path(file_name)
    timestamp = created_at.strftime('%Y_%j_%H_%M_%S_%L')
    ext = File.extname(file_name).empty? ? ".zip" : File.extname(file_name)
    File.join Rails.application.config.submissions_path,  "#{id}_#{timestamp}#{ext}"
  end

  def is_viewable_by?(user)
    user.teacher? || !hidden
  end


  def self.viewable_by_user(user)
    if user.teacher?
      self
    else
      where(hidden: false)
    end
  end
end
