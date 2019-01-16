# == Schema Information
#
# Table name: courses
#
#  id          :integer          not null, primary key
#  description :text             not null
#  name        :string           not null
#  published   :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_courses_on_name       (name) UNIQUE
#  index_courses_on_published  (published)
#

require 'rails_helper'

RSpec.describe Course, type: :model do
  let(:subject) { FactoryGirl.create(:course) }
  it { should validate_presence_of :name }
  it { should validate_presence_of :description }
  it { should validate_uniqueness_of(:name).case_insensitive }
  it { should have_many :projects }
  it { should have_many :students }
  it { should have_many :studentships }

  describe 'validations' do
    let(:course) { FactoryGirl.build(:course) }
    it 'has a valid factory' do
      expect(course).to be_valid
    end
    context 'name is nil' do
      let(:course) { FactoryGirl.build(:course, name: nil) }
      it 'should not be valid' do
        expect(course).to_not be_valid
      end
    end
    context 'description is nil' do
      let(:course) { FactoryGirl.build(:course, description: nil) }
      it 'should not be valid' do
        expect(course).to_not be_valid
      end
    end
    context 'unique names' do
      let(:first) { FactoryGirl.build(:course) }
      let(:second) { FactoryGirl.build(:course) }
      it 'should not allow duplicate names' do
        first.name = second.name.upcase
        first.save!
        expect(second).to_not be_valid
      end
    end
  end

  describe 'default values' do
    context 'published' do
      let(:course) { FactoryGirl.build(:course) }
      it 'should be false by default' do
        expect(course).to be_valid
        course.save!
        expect(course.published).to be false
      end
    end
  end

  context 'notifications' do
    it 'sends created notification' do
      expect(Notifications::CoursesController).to receive(:publish).once
      FactoryGirl.create(:course)
    end
    it 'sends delted notification' do
      course = FactoryGirl.create(:course)
      expect(Notifications::CoursesController).to receive(:publish).once
      course.destroy
    end
    it 'sends published notification' do
      course = FactoryGirl.create(:course, published: false)
      expect(Notifications::CoursesController).to receive(:publish).twice
      course.published = true
      course.save!
    end
    it 'sends unpublished notificiation' do
      course = FactoryGirl.create(:course, published: true)
      expect(Notifications::CoursesController).to receive(:publish).twice
      course.published = false
      course.save!
    end
  end
end
