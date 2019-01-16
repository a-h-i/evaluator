# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string           not null
#  guc_prefix      :integer
#  guc_suffix      :integer
#  major           :string
#  name            :string           not null
#  password_digest :string           not null
#  student         :boolean          not null
#  super_user      :boolean          default(FALSE), not null
#  team            :string
#  verified        :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
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

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_secure_password }
  it { should have_many :studentships }
  it { should have_many :courses }
  it { should have_many :submissions }
  it { should have_many :reset_tokens }
  it { should have_many :verification_tokens }
  it { should validate_presence_of :name }
  it { should validate_presence_of :email }

  context 'student' do
    context 'validation' do
      let(:student) { FactoryGirl.build(:student) }
      it 'has a valid factory' do
        expect(student).to be_valid
      end
      it 'can not be super_user' do
        student.super_user = true
        expect(student).to_not be_valid
      end
      context 'email is nil' do
        let(:student) { FactoryGirl.build(:student, email: nil) }
        it 'should not be valid' do
          expect(student).to_not be_valid
        end
      end
      context 'email is belongs to a non guc domain' do
        let(:student) { FactoryGirl.build(:student, email: 'student@example.com') }
        it 'should not be valid' do
          expect(student).to_not be_valid
        end
      end
      context 'unique email' do
        let(:first) { FactoryGirl.create(:student) }
        let(:second) { FactoryGirl.build(:student) }
        it 'should not allow duplicate emails' do
          second.email = first.email.capitalize
          expect(second).to_not be_valid
        end
      end

      context 'name is nil' do
        let(:student) { FactoryGirl.build(:student, name: nil) }
        it 'should not be valid' do
          expect(student).to_not be_valid
        end
      end

      context 'password is nil' do
        let(:student) { FactoryGirl.build(:student, password: nil) }
        it 'should not be valid' do
          expect(student).to_not be_valid
        end
      end

      context 'password is less than 2 chatactes' do
        let(:student) { FactoryGirl.build(:student, password: 's') }
        it 'should not be valid' do
          expect(student).to_not be_valid
        end
      end

      context 'major is nil' do
        let(:student) { FactoryGirl.build(:student, major: nil) }
        it 'should not be valid' do
          expect(student).to_not be_valid
        end
      end

      context 'team is nil' do
        let(:student) { FactoryGirl.build(:student, team: nil) }
        it 'should not be valid' do
          expect(student).to_not be_valid
        end
      end

      context 'GUC id' do
        context 'only suffix is nil' do
          let(:student) { FactoryGirl.build(:student, guc_suffix: nil) }
          it 'should not be valid' do
            expect(student).to_not be_valid
          end
        end
        context 'only prefix is nil' do
          let(:student) { FactoryGirl.build(:student, guc_prefix: nil) }
          it 'should not be valid' do
            expect(student).to_not be_valid
          end
        end
        context 'suffix and prefix' do
          let(:student) { FactoryGirl.build(:student, guc_prefix: nil, guc_suffix: nil) }
          it 'should not be valid' do
            expect(student).to_not be_valid
          end
        end
      end
    end # Validations

    context 'type detection' do
      let(:student) { FactoryGirl.build(:student) }
      it "should know it's a student" do
        student.save!
        expect(student.student?).to be true
      end
    end

    context 'Token generation' do
      let(:student) { FactoryGirl.create(:student) }
      it 'should be able to create a token' do
        expect(student.token).to be_a_kind_of String
      end
      it 'should be able to retrive a student by its token' do
        token = student.token
        expect(User.find_by_token(token)).to eql student
      end
    end

    context 'GUC id attribute' do
      let(:student) { FactoryGirl.create(:student) }
      it 'should be constructed correctly from prefix and suffix' do
        expect(student.guc_id).to eql "#{student.guc_prefix}-#{student.guc_suffix}"
      end
      it 'should set prefix and suffix based on it' do
        student.guc_id = '99-32'
        expect(student.guc_prefix).to eql 99
        expect(student.guc_suffix).to eql 32
      end
    end
  end # Student specs

  context 'type scope' do
    let(:teachers) { FactoryGirl.create_list(:teacher, 10) }
    let(:students) { FactoryGirl.create_list(:student, 10) }
    it 'should query by teachers' do
      are_teachers = User.teachers.reduce(true) { |memo, user| memo && user.teacher? }
      expect(are_teachers).to be true
    end
    it 'should query by students' do
      are_students = User.students.reduce(true) { |memo, user| memo && user.student? }
      expect(are_students).to be true
    end
  end

  context 'Teacher' do
    context 'validation' do
      let(:teacher) { FactoryGirl.build(:teacher) }
      it 'has a valid factory' do
        expect(teacher).to be_valid
      end
      context 'email is nil' do
        let(:teacher) { FactoryGirl.build(:teacher, email: nil) }
        it 'should not be valid' do
          expect(teacher).to_not be_valid
        end
      end
      context 'email is belongs to a non guc domain' do
        let(:teacher) { FactoryGirl.build(:teacher, email: 'teacher@example.com') }
        it 'should not be valid' do
          expect(teacher).to_not be_valid
        end
      end
      context 'unique email' do
        let(:first) { FactoryGirl.create(:teacher) }
        let(:second) { FactoryGirl.build(:teacher) }
        it 'should not allow duplicate emails' do
          second.email = first.email.capitalize
          expect(second).to_not be_valid
        end
      end

      context 'name is nil' do
        let(:teacher) { FactoryGirl.build(:teacher, name: nil) }
        it 'should not be valid' do
          expect(teacher).to_not be_valid
        end
      end

      context 'password is nil' do
        let(:teacher) { FactoryGirl.build(:teacher, password: nil) }
        it 'should not be valid' do
          expect(teacher).to_not be_valid
        end
      end

      context 'password is less than 2 chatactes' do
        let(:teacher) { FactoryGirl.build(:teacher, password: 's') }
        it 'should not be valid' do
          expect(teacher).to_not be_valid
        end
      end
    end # Validations
    context 'type detection' do
      let(:teacher) { FactoryGirl.build(:teacher) }
      it "should know it's a teacher" do
        teacher.save!
        expect(teacher.teacher?).to be true
      end
    end

    context 'Token generation' do
      let(:teacher) { FactoryGirl.create(:teacher) }
      it 'should be able to create a token' do
        expect(teacher.token).to be_a_kind_of String
      end
      it 'should be able to retrive a teacher by its token' do
        token = teacher.token
        expect(User.find_by_token(token)).to eql teacher
      end
    end
  end # Teacher specs

  context 'Password reset' do
    let(:student) { FactoryGirl.create(:student, password: 'old password') }
    it 'should generate reset token' do
      expect(student).to respond_to :gen_reset_token
    end
    it 'should not generate new tokens unecessarily' do
      token_one = student.gen_reset_token
      token_two = student.gen_reset_token
      expect(token_one).to eql token_two
    end

    it 'should reset password with generated token' do
      newPass = 'new password'
      token = student.gen_reset_token
      expect(student.reset_password(token, newPass)).to be true
      expect(student.authenticate(newPass)).to be_truthy
    end

    it 'should not reset password with another token' do
      newPass = 'new password'
      student.gen_reset_token
      other = FactoryGirl.create(:teacher)
      token = other.gen_reset_token
      expect(student.reset_password(token, newPass)).to be false
      expect(student.authenticate(newPass)).to be false
    end
  end

  context 'verification' do
    let(:teacher) { FactoryGirl.create(:teacher, verified: false) }
    it 'should generate verification token' do
      expect(teacher).to respond_to :gen_verification_token
    end
    it 'should not generate new tokens unecessarily' do
      token_one = teacher.gen_verification_token
      token_two = teacher.gen_verification_token
      expect(token_one).to eql token_two
    end

    it 'should accept generated token' do
      expect(teacher.verified?).to be false
      token = teacher.gen_verification_token
      expect(teacher.verify(token)).to be true
      expect(teacher.verified?).to be true
    end

    it 'should not accept another token' do
      expect(teacher.verified?).to be false
      teacher.gen_verification_token
      other = FactoryGirl.create(:student)
      other_token = other.gen_verification_token
      expect(teacher.verify(other_token)).to be false
      expect(teacher.verified?).to be false
    end
  end

  context '.full_name' do
    let(:user) { FactoryGirl.create(:student, name: 'i am a student') }
    it 'is capitalized' do
      expect(user.full_name).to eql 'I Am A Student'
    end
  end

  context '.guc_id' do
    let(:user) { FactoryGirl.create(:student, guc_prefix: 1, guc_suffix: 12) }
    it 'is properly formatted' do
      expect(user.guc_id).to eql '1-12'
    end
  end

  context '.guc_id=' do
    let(:user) { FactoryGirl.create(:student, guc_prefix: 12, guc_suffix: 18) }
    it 'is properly set' do
      user.guc_id = '13-1800'
      expect(user.guc_suffix).to eql 1800
      expect(user.guc_prefix).to eql 13
    end
  end

  context '.can_view?' do
    context 'submissions' do
      it 'can view a submission if teacher' do
        subject = FactoryGirl.create(:teacher)
        submission = FactoryGirl.create(:submission)
        expect(subject.can_view?(submission)).to be true
      end
      it 'can view a submission if submitter' do
        subject = FactoryGirl.create(:student)
        submission = FactoryGirl.create(:submission, submitter: subject)
        expect(subject.can_view?(submission)).to be true
      end
      it 'can not view a submission if unrelated student' do
        subject = FactoryGirl.create(:student)
        submission = FactoryGirl.create(:submission)
        expect(subject.can_view?(submission)).to be false
      end
    end
    context 'test suite' do
      let(:suite) { FactoryGirl.create(:test_suite) }
      it 'can view if a teacher' do
        subject = FactoryGirl.create(:teacher)
        expect(subject.can_view?(suite)).to be true
      end
      it 'can not view if a student' do
        subject = FactoryGirl.create(:student)
        expect(subject.can_view?(suite)).to be false
      end
    end
    context 'result' do
      let(:result) { FactoryGirl.create(:result) }
      it 'can view if teacher' do
        subject = FactoryGirl.create(:teacher)
        expect(subject.can_view?(result)).to be true
      end
      it 'can view  if submitter' do
        subject = result.submission.submitter
        expect(subject.can_view?(result)).to be true
      end
      it 'can not view if same team' do
        subject = FactoryGirl.create(:student, team: result.submission.submitter.team)
        expect(subject.can_view?(result)).to be false
      end
      it 'can not view a result if another student' do
        subject = FactoryGirl.create(:student, team: 'haha team')
        expect(subject.can_view?(result)).to be false
      end
    end
    context 'other objects' do
      let(:object) { FactoryGirl.create(:teacher) }
      it 'can view other objects' do
        subject = FactoryGirl.create(:student)
        expect(subject.can_view?(object)).to be true
      end
    end
  end
end
