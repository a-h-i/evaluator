# == Schema Information
#
# Table name: projects
#
#  id                   :bigint(8)        not null, primary key
#  course_id            :bigint(8)        not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  due_date             :datetime         not null
#  start_date           :datetime         not null
#  name                 :text             not null
#  published            :boolean          default(FALSE), not null
#  quiz                 :boolean          default(FALSE), not null
#  reruning_submissions :boolean          default(FALSE), not null
#  detail               :json             not null
#
# Indexes
#
#  index_projects_on_course_id                 (course_id)
#  index_projects_on_created_at_and_published  (created_at DESC,published)
#  projects_course_id_name_key                 (course_id,name) UNIQUE
#

class Project < ApplicationRecord
  include Cachable
  has_many :submissions, dependent: :destroy
  has_many :test_suites, dependent: :destroy
  # destroyed via test_suites
  has_many :results
  belongs_to :course
  scope :published, -> { where published: true }
  scope :not_published, -> { where published: false }
  scope :due, -> { where "due_date <= ?", DateTime.now }
  scope :not_due, -> { where "due_date > ?", DateTime.now }
  scope :started, -> { where "start_date <= ?", DateTime.now }
  validates :name, :due_date, :course, presence: true
  validates :name, uniqueness: { case_sensitive: false, scope: :course_id }
  validate :detail_validation
  JAVA_8_SPEC_TYPE = 0x01
  JUNIT_3_SUB_TYPE = 0x01
  JUNIT_4_SUB_TYPE = 0x02
  JUNIT_5_SUB_TYPE = 0x03

  def viewable_by_user?(user)
    user.teacher? || (published && StudentCourseRegistration.exists?(student_id: user.id, course_id: course_id))
  end

  def can_submit?
    due_date.utc > DateTime.now.utc && start_date.utc <= DateTime.now.utc
  end

  def set_detail_value(name, value)
    if self.detail.nil?
      self.detail = Hash.new
    end
    detail[name.to_s] = value
  end

  def get_detail_value(name)
    if self.detail.nil?
      self.detail = Hash.new
      return nil
    else
      self.detail[name.to_s]
    end
  end

  def spec_type=(value)
    set_detail_value(:spec_type, value)
  end

  def spec_type
    return get_detail_value(:spec_type)
  end

  def spec_subtype=(value)
    set_detail_value(:spec_subtype, value)
  end

  def spec_subtype
    return get_detail_value(:spec_subtype)
  end

  def dependencies=(value)
    set_detail_value(:dependencies, value)
  end

  def dependencies
    get_detail_value(:dependencies)
  end

  private

  def detail_validation
    if (dependencies.nil? || spec_subtype.nil? || spec_type.nil?)
      errors.add(:detail, "Must have correct detail")
    end
  end
end
