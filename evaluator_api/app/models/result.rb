# == Schema Information
#
# Table name: results
#
#  id              :integer          not null, primary key
#  compiled        :boolean          not null
#  compiler_stderr :text             not null
#  compiler_stdout :text             not null
#  grade           :integer          not null
#  hidden          :boolean          not null
#  max_grade       :integer          not null
#  success         :boolean          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  project_id      :integer
#  submission_id   :integer
#  test_suite_id   :integer
#
# Indexes
#
#  index_results_on_project_id     (project_id)
#  index_results_on_submission_id  (submission_id)
#  index_results_on_test_suite_id  (test_suite_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id) ON DELETE => cascade
#  fk_rails_...  (submission_id => submissions.id) ON DELETE => cascade
#  fk_rails_...  (test_suite_id => test_suites.id) ON DELETE => cascade
#

# Represents results for an individual submission.
# This is different than team results
class Result < ActiveRecord::Base
  include Cacheable
  belongs_to :submission
  belongs_to :test_suite
  belongs_to :project
  validates :submission, :test_suite, :project, presence: true
  validates :compiler_stderr, :compiler_stdout, :grade, :max_grade, presence: true
  has_many :test_cases, dependent: :delete_all
  validate :grade_range
  validate :boolean_validations
  before_save :set_hidden

  # Can not view hidden results
  # Can view results that belong to a team's own submission
  def self.viewable_by_user(user)
    if user.student?
      Result.joins(:submission).where(submissions: {
        submitter_id: user.id})
    else
      self
    end
  end

  def as_json(_options = {})
    super(include: [:test_suite, :test_cases])
  end

  private

  def grade_range
    if !max_grade.nil? && !grade.nil? && !grade.between?(0, max_grade)
      errors.add(:grade, "must be between 0 and #{max_grade}")
    end
  end

  def set_hidden
    self.hidden = test_suite.hidden.to_s
  end

  def boolean_validations
    errors.add(:compiled, 'can not be blank') if compiled.nil?
    errors.add(:success, 'can not be blank') if success.nil?
  end
end
