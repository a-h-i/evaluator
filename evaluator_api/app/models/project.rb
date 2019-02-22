class Project < ApplicationRecord
  include Cachable
  has_many :submissions, dependent: :destroy
  has_many :test_suites, dependent: :destroy
  belongs_to :course
  scope :published, -> { where published: true }
  scope :not_published, -> { where published: false }
  scope :due, ->  { where 'due_date <= ?', DateTime.now }
  scope :not_due, -> { where 'due_date > ?', DateTime.now }
  scope :started, -> { where 'start_date <= ?', DateTime.now }
  validates :name, :due_date, :course, presence: true
  validates :name, uniqueness: {case_sensitive: false, scope: :course}

end
