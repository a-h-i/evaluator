# == Schema Information
#
# Table name: courses
#
#  id          :bigint(8)        not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  name        :text             not null
#  description :text             not null
#  published   :boolean          default(FALSE), not null
#
# Indexes
#
#  courses_name_key                           (name) UNIQUE
#  index_courses_on_created_at_and_published  (created_at,published)
#

require "rails_helper"

RSpec.describe Course, type: :model do
  let(:subject) { FactoryBot.create(:course) }
  it { should validate_presence_of :name }
  it { should validate_presence_of :description }
  it { should validate_uniqueness_of(:name).case_insensitive }
  it { should have_many :projects }
  it { should have_many :students }
  it { should have_many :student_course_registrations }

  describe 'factory' do
    let(:course) { FactoryBot.build(:course) }
    it 'has a valid factory' do
      expect(course).to be_valid
    end
  end

  describe 'default values' do
    context 'published' do
      let(:course) { FactoryBot.build(:course) }
      it 'should be false by default' do
        expect(course).to be_valid
        course.save!
        expect(course.published).to be false
      end
    end
  end

  
end
