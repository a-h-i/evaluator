# == Schema Information
#
# Table name: student_course_registrations
#
#  id         :bigint(8)        not null, primary key
#  course_id  :bigint(8)        not null
#  student_id :bigint(8)        not null
#  team       :text
#
# Indexes
#
#  index_student_course_registrations_on_student_id_and_course_id  (student_id,course_id)
#  student_course_registrations_course_id_student_id_key           (course_id,student_id) UNIQUE
#

require 'rails_helper'

RSpec.describe StudentCourseRegistration, type: :model do
  it { should belong_to :course }
  it { should belong_to :student }
  it { should validate_presence_of :course }
  it { should validate_presence_of :student }
  
  describe 'factory' do
    let(:student_course_registration) { FactoryBot.build(:student_course_registration) }
    it 'should be valid' do
      expect(student_course_registration).to be_valid
    end
  end

  describe 'team propagation', focus: true do
    let(:submission) {FactoryBot.create(:submission)}

    it 'sets team' do
      expect(submission.team).to be_nil
      submission.course.unregister submission.submitter
      submission.course.register submission.submitter, 'test team please ignore'
      submission.reload
      expect(submission.team).to eql 'test team please ignore'
    end
  end


  describe 'course students' do
    context 'create joins' do
      let(:students) { FactoryBot.create_list(:student, 3) }
      let(:course) { FactoryBot.create(:course) }
      it 'should be accessible from the other side' do
        course.students << students
        course.save!
        linked = students.reduce { |memo, student| memo && student.courses.first.id == course.id }
        expect(linked).to be true
      end
    end
    context 'delete on dependency' do
      let(:course) { FactoryBot.create(:course) }
      let(:students) { FactoryBot.create_list(:student, 2) }
      it 'join records should be deleted' do
        course.students << students
        course.save!
        expect(StudentCourseRegistration.where(course_id: course.id).count).to eql 2
        course.destroy
        expect(StudentCourseRegistration.where(course_id: course.id).count).to eql 0
      end
    end
  end

  describe 'student courses' do
    context 'create joins' do
      let(:student) { FactoryBot.create(:student) }
      let(:courses) { FactoryBot.create_list(:course, 5) }
      it 'should be accessible from the other side' do
        student.courses << courses
        student.save!
        linked = courses.reduce { |memo, course| memo && course.students.first.id == student.id }
        expect(linked).to be true
      end
    end
    context 'delete on dependency' do
      let(:student) { FactoryBot.create(:student) }
      let(:courses) { FactoryBot.create_list(:course, 3) }
      it 'join records should be deleted' do
        student.courses << courses
        student.save!
        expect(StudentCourseRegistration.where(student_id: student.id).count).to eql 3
        student.destroy
        expect(StudentCourseRegistration.where(student_id: student.id).count).to eql 0
      end
    end
  end
end
