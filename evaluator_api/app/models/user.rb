class User < ApplicationRecord
  include JwtAuthenticatable
  GUC_EMAIL_REGEX = /\A[a-zA-Z\.\-]+@(student.)?guc.edu.eg\z/
  STUDENT_EMAIL_REGEX = /\A[a-zA-Z\.\-]+@student.guc.edu.eg\z/
  before_validation :downcase_email
  before_validation :set_subtype
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format: { with: GUC_EMAIL_REGEX, message: "must be a GUC email" }
  validate :email_not_changed
  validate :student_fields
  validate :super_user_teacher
  scope :students, -> { where student: true }
  scope :teachers, -> { where student: false } 
  has_many :submissions, inverse_of: :submitter, foreign_key: :submitter_id,
                         dependent: :destroy
  # dependent deletion for registration done at db level                         
  has_many :student_course_registrations, inverse_of: :student, foreign_key: :student_id
  has_many :courses, through: :student_course_registrations

  def guc_id
    "#{guc_prefix}-#{guc_suffix}"
  end

  def guc_id=(value)
    guc_prefix, guc_suffix = value.split "-"
    self.guc_prefix = guc_prefix.to_i
    self.guc_suffix = guc_suffix.to_i
  end

  def teacher?
    !student
  end

  def allowed_login?
    verified? && (student? || verified_teacher?)
  end

  private

  def super_user_teacher
    errors.add(:super_user, 'Must be a teacher') if student? && super_user?
  end

  def email_not_changed
    errors.add(:email, "can not be changed") if email_changed? && persisted?
  end

  def set_subtype
    self.student = (STUDENT_EMAIL_REGEX === email).to_s unless persisted?
  end

  def downcase_email
    self.email = email.downcase unless email.nil? if email_changed?
  end

  def student_fields
    if student?
      errors.add(:major, "is required") if major.nil?
      errors.add(:study_group, "is required") if study_group.nil?
      if guc_prefix.nil? || guc_suffix.nil?
        errors.add("guc_id", "is required")
      end
    end
  end
end
