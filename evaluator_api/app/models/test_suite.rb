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
#
# Indexes
#
#  test_suites_project_id_name_key  (project_id,name) UNIQUE
#

class TestSuite < ApplicationRecord
  include FileSanitizer
  include FileAttachable
  belongs_to :project
  has_many :results, dependent: :destroy
  validates :name, :project, presence: true
  validates :name, uniqueness: { case_sensitive: false, scope: :project_id }
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

end
