require "rails_helper"

RSpec.describe Course, type: :model do
  let(:subject) { FactoryBot.create(:course) }
  it { should validate_presence_of :name }
  it { should validate_presence_of :description }
  it { should validate_uniqueness_of(:name).case_insensitive }
  it { should have_many :projects }
  it { should have_many :students }
  it { should have_many :student_course_registrations }
  it { should have_many :test_suites }
end
