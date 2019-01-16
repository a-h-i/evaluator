# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  password_digest :string           not null
#  email           :string           not null
#  student         :boolean          not null
#  verified        :boolean          default(FALSE), not null
#  major           :string
#  team            :string
#  guc_suffix      :integer
#  guc_prefix      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  super_user      :boolean          default(FALSE), not null
#
# Indexes
#
#  index_users_on_email       (email) UNIQUE
#  index_users_on_guc_prefix  (guc_prefix)
#  index_users_on_guc_suffix  (guc_suffix)
#  index_users_on_name        (name)
#  index_users_on_student     (student)
#  index_users_on_super_user  (super_user)
#  index_users_on_team        (team)
#

# This model represents any user
# The following are sub types:
# 1 - Student
# 2 - Teacher
# 3 - Super User (special sub type for Teacher)
class User < ActiveRecord::Base
  has_secure_password
  include JwtAuthenticatable
  include EmailVerifiable
  include PasswordResetable
  include Cacheable
  STUDENT_EMAIL_REGEX = /\A[a-zA-Z\.\-]+@student.guc.edu.eg\z/
  TEACHER_EMAIL_REGEX = /\A[a-zA-Z\.\-]+@guc.edu.eg\z/
  GUC_EMAIL_REGEX = /\A[a-zA-Z\.\-]+@(student.)?guc.edu.eg\z/
  validates :password, length: { minimum: 2 }, allow_nil: true
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates_format_of :email, with: GUC_EMAIL_REGEX,
                              message: 'must be a GUC email'
  validate :email_not_changed
  validate :student_fields
  validate :super_user_teacher
  before_validation :set_subtype
  scope :students, -> { where student: true }
  scope :teachers, -> { where student: false }
  scope :admins, -> { where super_user: true }
  has_many :studentships, inverse_of: :student, foreign_key: :student_id
  has_many :courses, through: :studentships, dependent: :delete_all
  has_many :submissions, inverse_of: :submitter, foreign_key: :submitter_id,
                         dependent: :destroy
  def teacher?
    !student?
  end

  def team_grades
    Submission.where(team: team)
  end

  def full_name
    name.split.map(&:capitalize).join ' '
  end

  def as_json(_options = {})
    super(except: [:password_digest],
          methods: [:guc_id, :full_name]
    )
  end

  def can_view?(object)
    if object.is_a? Submission
      can_view_submission? object
    elsif object.is_a? Result
      can_view_result? object
    elsif object.is_a? TestSuite
      can_view_test_suite? object
    elsif object.is_a? Project
      can_view_project? object
    else
      true
    end
  end

  def self.queriable_fields
    un_permitted = [:created_at, :updated_at, :verified, :password_digest]
    all_fields = User.attribute_names.map(&:to_sym)
    all_fields - un_permitted
  end

  def guc_id
    "#{guc_prefix}-#{guc_suffix}"
  end

  def guc_id=(value)
    guc_prefix, guc_suffix = value.split '-'
    self.guc_prefix = guc_prefix.to_i
    self.guc_suffix = guc_suffix.to_i
  end

  def self.find_by_guc_id(guc_id)
    guc_prefix, guc_suffix = guc_id.split '-'
    find_by(guc_suffix: guc_suffix, guc_prefix: guc_prefix)
  end

  private

  def can_view_submission?(submission)
    teacher? || submission.submitter == self
  end

  def can_view_result?(result)
    teacher? || result.submission.submitter == self
  end

  def can_view_test_suite?(suite)
    teacher? || (!suite.hidden && can_view_project?(suite.project))
  end

  def can_view_project?(project)
    teacher? || (project.published && project.course.published)
  end

  def email_not_changed
    errors.add(:email, 'can not be changed') if email_changed? && persisted?
  end

  def student_fields
    if student?
      errors.add(:major, 'is required') unless major.is_a? String
      errors.add(:team, 'is required') unless team.is_a? String
      unless guc_prefix.is_a?(Integer) && guc_suffix.is_a?(Integer)
        errors.add('GUC id', 'is required')
      end
    end
  end

  def super_user_teacher
    errors.add(:super_user, 'Must be a teacher') if student? && super_user?
  end

  def set_subtype
    self.student = (STUDENT_EMAIL_REGEX === email).to_s
  end
  
end
