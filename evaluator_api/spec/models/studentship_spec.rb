# == Schema Information
#
# Table name: studentships
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  course_id  :integer
#  student_id :integer
#
# Indexes
#
#  index_studentships_on_course_id   (course_id)
#  index_studentships_on_student_id  (student_id)
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id) ON DELETE => cascade
#  fk_rails_...  (student_id => users.id) ON DELETE => cascade
#

require 'rails_helper'

RSpec.describe Studentship, type: :model do
  it { should belong_to :course }
  it { should belong_to :student }
  it { should validate_presence_of :course }
  it { should validate_presence_of :student }
  describe 'factory' do
    let(:studentship) { FactoryGirl.build(:studentship) }
    it 'should be valid' do
      expect(studentship).to be_valid
    end
  end

  describe 'course students' do
    context 'create joins' do
      let(:students) { FactoryGirl.create_list(:student, 3) }
      let(:course) { FactoryGirl.create(:course) }
      it 'should be accessible from the other side' do
        course.students << students
        course.save!
        linked = students.reduce { |memo, student| memo && student.courses.first.id == course.id }
        expect(linked).to be true
      end
    end
    context 'delete on dependency' do
      let(:course) { FactoryGirl.create(:course) }
      let(:students) { FactoryGirl.create_list(:student, 2) }
      it 'join records should be deleted' do
        course.students << students
        course.save!
        expect(Studentship.where(course_id: course.id).count).to eql 2
        course.destroy
        expect(Studentship.where(course_id: course.id).count).to eql 0
      end
    end
  end

  describe 'student courses' do
    context 'create joints' do
      let(:student) { FactoryGirl.create(:student) }
      let(:courses) { FactoryGirl.create_list(:course, 5) }
      it 'should be accessible from the other side' do
        student.courses << courses
        student.save!
        linked = courses.reduce { |memo, course| memo && course.students.first.id == student.id }
        expect(linked).to be true
      end
    end
    context 'delete on dependency' do
      let(:student) { FactoryGirl.create(:student) }
      let(:courses) { FactoryGirl.create_list(:course, 3) }
      it 'join records should be deleted' do
        student.courses << courses
        student.save!
        expect(Studentship.where(student_id: student.id).count).to eql 3
        student.destroy
        expect(Studentship.where(student_id: student.id).count).to eql 0
      end
    end
  end
end
