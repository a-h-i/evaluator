# == Schema Information
#
# Table name: results
#
#  id            :bigint(8)        not null, primary key
#  submission_id :bigint(8)        not null
#  project_id    :bigint(8)        not null
#  test_suite_id :bigint(8)        not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  max_grade     :integer          not null
#  grade         :integer          not null
#  success       :boolean          not null
#  hidden        :boolean          not null
#  detail        :jsonb            not null
#
# Indexes
#
#  index_results_on_submission_id  (submission_id)
#

class Result < ApplicationRecord
  include Cachable
  belongs_to :submission
  belongs_to :test_suite
  belongs_to :project
  validates :submission, :test_suite, :project, presence: true
  validates :grade, :max_grade, :success, :detail, presence: true
  validate :grade_range
  before_save :set_hidden


  def as_json(_options = {})
    super(include: [:test_suite])
  end
  private
  def set_hidden
    self.hidden = test_suite.hidden.to_s
  end
  def grade_range
    if !max_grade.nil? && !grade.nil? && !grade.between?(0, max_grade)
      errors.add(:grade, "must be between 0 and #{max_grade}")
    end
  end


end
