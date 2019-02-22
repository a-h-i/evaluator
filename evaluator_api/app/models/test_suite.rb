class TestSuite < ApplicationRecord
  belongs_to :project
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false, scope: :project }
end
