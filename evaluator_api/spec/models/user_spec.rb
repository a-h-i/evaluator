# == Schema Information
#
# Table name: users
#
#  id               :bigint(8)        not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  guc_prefix       :integer
#  guc_suffix       :integer
#  password_digest  :text             not null
#  name             :text             not null
#  email            :text             not null
#  major            :text
#  study_group      :text
#  verified         :boolean          default(FALSE), not null
#  verified_teacher :boolean          default(FALSE), not null
#  super_user       :boolean          default(FALSE), not null
#  student          :boolean          default(TRUE), not null
#

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many :student_course_registrations }
  it { should have_many :courses }
  it { should have_many :submissions }
  it { should validate_presence_of :name }
  it { should validate_presence_of :email }
  it { validate_uniqueness_of(:email).case_insensitive}

  context 'student' do 
    context 'validation' do
      let(:student) { FactoryBot.build(:student) }
      it 'has a valid factory' do
        expect(student).to be_valid
      end
      it 'can not be super_user' do
        student.super_user = true
        expect(student).to_not be_valid
      end

      context 'email belongs to a non guc domain' do
        let(:student) { FactoryBot.build(:student, email: 'student@example.com') }
        it 'should not be valid' do
          expect(student).to_not be_valid
        end
      end

      context 'password is nil' do
        let(:student) { FactoryBot.build(:student, password: nil) }
        it 'should not be valid' do
          expect(student).to_not be_valid
        end
      end

      context 'password is less than 2 characters' do
        let(:student) { FactoryBot.build(:student, password: 's') }
        it 'should not be valid' do
          expect(student).to_not be_valid
        end
      end

      context 'major is nil' do
        let(:student) { FactoryBot.build(:student, major: nil) }
        it 'should not be valid' do
          expect(student).to_not be_valid
        end
      end

      context 'GUC id' do
        context 'only suffix is nil' do
          let(:student) { FactoryBot.build(:student, guc_suffix: nil) }
          it 'should not be valid' do
            expect(student).to_not be_valid
          end
        end
        context 'only prefix is nil' do
          let(:student) { FactoryBot.build(:student, guc_prefix: nil) }
          it 'should not be valid' do
            expect(student).to_not be_valid
          end
        end
        context 'suffix and prefix' do
          let(:student) { FactoryBot.build(:student, guc_prefix: nil, guc_suffix: nil) }
          it 'should not be valid' do
            expect(student).to_not be_valid
          end
        end
      end
    end # Validations
    context 'Token generation' do
      let(:student) { FactoryBot.create(:student, password: 'not password') }
      it 'should be able to create a token' do
        expect(student.token).to be_a_kind_of String
      end
      it 'should be able to retrive a student by its token' do
        token = student.token
        expect(User.find_by_token(token)).to eql student
      end
      it 'should fail on changed password' do
        token = student.token
        student.password = 'password'
        student.save
        expect {User.find_by_token(token) }.to raise_error(AuthenticationError)
      end
    end
  end

  context 'type scope' do
    let(:teachers) { FactoryBot.create_list(:teacher, 10) }
    let(:students) { FactoryBot.create_list(:student, 10) }
    it 'should query by teachers' do
      are_teachers = User.teachers.reduce(true) { |memo, user| memo && user.teacher? }
      expect(are_teachers).to be true
    end
    it 'should query by students' do
      are_students = User.students.reduce(true) { |memo, user| memo && user.student? }
      expect(are_students).to be true
    end
  end

  context 'teacher' do
    context 'validation' do
      let(:teacher) { FactoryBot.build(:teacher) }
      it 'has a valid factory' do
        expect(teacher).to be_valid
      end
      
      context 'email is belongs to a non guc domain' do
        let(:teacher) { FactoryBot.build(:teacher, email: 'teacher@example.com') }
        it 'should not be valid' do
          expect(teacher).to_not be_valid
        end
      end
      

      context 'password is nil' do
        let(:teacher) { FactoryBot.build(:teacher, password: nil) }
        it 'should not be valid' do
          expect(teacher).to_not be_valid
        end
      end

      context 'password is less than 2 chatactes' do
        let(:teacher) { FactoryBot.build(:teacher, password: 's') }
        it 'should not be valid' do
          expect(teacher).to_not be_valid
        end
      end
    end # Validations
    context 'type detection' do
      let(:teacher) { FactoryBot.build(:teacher) }
      it "should know it's a teacher" do
        teacher.save!
        expect(teacher.teacher?).to be true
      end
    end

    context 'Token generation' do
      let(:teacher) { FactoryBot.create(:teacher) }
      it 'should be able to create a token' do
        expect(teacher.token).to be_a_kind_of String
      end
      it 'should be able to retrive a teacher by its token' do
        token = teacher.token
        expect(User.find_by_token(token)).to eql teacher
      end
      it 'should fail on changed password' do
        token = teacher.token
        teacher.password = 'password'
        teacher.save
        expect {User.find_by_token(token) }.to raise_error(AuthenticationError)
      end
    end
  end

  context '.guc_id' do
    let(:user) { FactoryBot.create(:student, guc_prefix: 1, guc_suffix: 12) }
    it 'is properly formatted' do
      expect(user.guc_id).to eql '1-12'
    end
  end

  context '.guc_id=' do
    let(:user) { FactoryBot.create(:student, guc_prefix: 12, guc_suffix: 18) }
    it 'is properly set' do
      user.guc_id = '13-1800'
      expect(user.guc_suffix).to eql 1800
      expect(user.guc_prefix).to eql 13
    end
  end


  
end
