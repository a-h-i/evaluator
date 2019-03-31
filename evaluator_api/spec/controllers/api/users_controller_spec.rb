require "rails_helper"

RSpec.describe Api::UsersController, type: :controller do
  context ".index" do
    let(:students) { FactoryBot.create_list(:student, 9) }
    let(:teachers) { FactoryBot.create_list(:teacher, 9) }
    let(:student) { FactoryBot.create(:student) }
    let(:teacher) { FactoryBot.create(:teacher) }
    it "disallow unauthoried index" do
      get :index, format: :json
      expect(response).to be_unauthorized
    end
    it "respond to index action" do
      set_token teacher.token
      get :index, format: :json
      expect(response.successful?).to be true
    end
    it "has pagination" do
      set_token teacher.token
      get :index, params: {page: 1, page_size: students.length}
      expect(response.successful?).to be true
      expect(json_response).to include(
        :users, :page, :page_size, :total_pages
      )
      expect(json_response[:users].length).to be students.length
      expected_total_pages = (students.length + teachers.length) % students.length + 2
      expect(json_response[:total_pages]).to eql expected_total_pages
    end

    it "disallow student" do
      set_token student.token
      get :index, format: :json, params: {page: 1, page_size: students.length}
      expect(response).to be_forbidden
    end

    it "return all records" do
      set_token teacher.token
      get :index, format: :json, params: {page: 1, page_size: students.length + teachers.length}
      expect(json_response).to include(
        :users, :page, :page_size, :total_pages
      )
      expect(json_response[:total_pages]).to eql 2 # extra user for authentication
      expect(json_response[:page_size]).to eql students.length + teachers.length
      are_equal = json_response[:users].reduce true do |memo, responseUser|
        check = -> (other) { responseUser[:id] == other.id }
        memo && (teacher.id == responseUser[:id] || students.any?(&check) || teachers.any?(&check))
      end
      expect(are_equal).to be true
    end
  end

  context ".show" do
    let(:student) { FactoryBot.create(:student) }
    it "disallow unauthorized requests" do
      get :show, format: :json, params: {id: student.id}
      expect(response).to be_unauthorized
    end
    it "show the correct user" do
      set_token student.token
      get :show, format: :json, params: {id: student.id}
      expect(response.successful?).to be true
      expect(json_response[:id]).to eql student.id
      expect(json_response).to include(
        :id, :email, :student, :major, :guc_suffix, :guc_prefix, :name,
        :verified
      )
      expect(json_response).to_not include(
        :password_digest, :password
      )
    end
    it "does not allow student to view other" do
      other = FactoryBot.create(:student)
      set_token other.token
      get :show, format: :json, params: {id: student.id}
      expect(response).to be_forbidden
    end
    it "allows teacher to view other" do
      other = FactoryBot.create(:teacher)
      set_token other.token
      get :show, format: :json, params: {id: student.id}
      expect(json_response).to include(
        :id, :email, :student, :major, :guc_suffix, :guc_prefix, :name,
        :verified
      )
      expect(json_response).to_not include(
        :password_digest, :password
      )
    end
  end

  context ".update" do
    let(:student_one) { FactoryBot.create(:student) }
    let(:student_two) { FactoryBot.create(:student) }
    let(:teacher_one) { FactoryBot.create(:teacher) }
    let(:teacher_two) { FactoryBot.create(:teacher) }
    let(:admin) { FactoryBot.create(:super_user) }
    it "allows a super user to set another teacher as a super user" do
      set_token admin.token
      put :update, params: { id: teacher_one.id, super_user: true }, format: :json
      expect(response.successful?).to be true
      teacher_one.reload
      expect(teacher_one.super_user?).to be true
    end
    it "does not allow a super user to set a student as a super user" do
      set_token admin.token
      put :update, params: { id: student_one.id, super_user: true }, format: :json
      expect(response).to be_unprocessable
      student_one.reload
      expect(student_one.super_user?).to be false
    end
    it "disallow unauthorized updates" do
      old_digest = student_one.password_digest
      put :update, params: { id: student_one.id, password: "new password!" }, format: :json
      expect(response).to be_unauthorized
      student_one.reload
      expect(student_one.password_digest).to eql old_digest
    end

    it "disallow a user to change another user" do
      old_digest = teacher_one.password_digest
      set_token student_two.token
      put :update, params: { id: teacher_one.id, password: "new password!" }, format: :json
      expect(response).to be_forbidden
      teacher_one.reload
      expect(teacher_one.password_digest).to eql old_digest
    end

    it "allow a user to modify its fields" do
      old_digest = teacher_one.password_digest
      set_token teacher_one.token
      put :update, params: { id: teacher_one.id, password: "new password!" }, format: :json
      expect(response.successful?).to be true
      teacher_one.reload
      expect(teacher_one.password_digest).to_not eql old_digest
    end

    it "disallow a user to modify its email" do
      teacher_one.reload
      old_json = teacher_one.as_json
      set_token teacher_one.token
      put :update, params: { id: teacher_one.id, email: "newteach@guc.edu.eg" }, format: :json
      expect(response).to be_unprocessable
      teacher_one.reload
      expect(teacher_one.as_json).to match old_json
    end

    it "allow a user to modify more than one field" do
      student_two.reload
      old_json = student_two.as_json
      set_token student_two.token
      put :update, params: { id: student_two.id, password: "new password!", name: "new name!" }, format: :json
      expect(response.successful?).to be true
      student_two.reload
      expect(student_two.as_json).to_not match old_json
    end

    it "disallow a user to change its type" do
      set_token student_two.token
      put :update, params: { id: student_two.id, student: false }, format: :json
      expect(response.successful?).to be true
      student_two.reload
      expect(student_two.student?).to be true
    end

    it "disallow a teacher from becoming a super user" do
      set_token teacher_one.token
      put :update, params: { id: teacher_one.id, super_user: true }, format: :json
      expect(response.successful?).to be true
      teacher_one.reload
      expect(teacher_one.super_user?).to be false
    end

    it "disallow a student from becoming a super user" do
      set_token student_one.token
      put :update, params: { id: student_one.id, super_user: true }, format: :json
      expect(response.successful?).to be true
      student_one.reload
      expect(student_one.super_user?).to be false
    end

    it "disallow a user to change verification" do
      set_token teacher_two.token
      put :update, params: { id: teacher_two.id, verified: false }, format: :json
      expect(response.successful?).to be true
      teacher_two.reload
      expect(teacher_two.verified?).to be true
    end

    it "allows an admin to change another user" do
      old_major = student_one.major
      set_token admin.token
      put :update, params: {id: student_one.id, major: old_major + "3"}, format: :json
      student_one.reload
      expect(response.successful?).to be true
      expect(student_one.major).to_not eql old_major
    end
  end

  context ".create" do
    let(:student_params) { FactoryBot.attributes_for(:student) }
    let(:teacher_params) { FactoryBot.attributes_for(:teacher) }
    context "with valid params" do
      it "create a new student" do
        expect do
          post :create, params: student_params, format: :json
        end.to change(User, :count).by 1
        expect(response).to be_created
      end
      it "create a new teacher" do
        expect do
          post :create, format: :json, params: teacher_params
        end.to change(User, :count).by 1
        expect(response).to be_created
      end

      it "set new users to unverified" do
        post :create, format: :json, params: teacher_params
        user = User.find json_response[:id]
        expect(user.verified?).to be false
      end
      it "creates verification token" do
        allow(MessagingService).to receive(:send_verification_email)
        post :create, format: :json, params: teacher_params
        expect(MessagingService).to have_received(:send_verification_email)
      end
    end
    context "with invalid params" do
      it "disallow a user to set type" do
        student_params[:student] = false
        post :create, format: :json, params: student_params
        expect(json_response[:student]).to be true
        expect(response).to be_created
      end
      it "disallow a user to set admin" do
        teacher_params[:super_user] = true
        post :create, format: :json, params: teacher_params
        expect(json_response[:super_user]).to be false
        expect(response).to be_created
      end
      it "disallow users to set verified" do
        teacher_params[:verified] = true
        post :create, format: :json, params: teacher_params
        expect(json_response[:verified]).to be false
        expect(response).to be_created
      end
      it "disallow invalid params" do
        teacher_params.delete :email
        expect do
          post :create, format: :json, params: teacher_params
        end.to change(User, :count).by 0
        expect(response).to be_unprocessable
      end
    end
  end
  context ".reset_password" do
    let(:user) { FactoryBot.create(:teacher, verified: true) }
    it "should send reset email" do
      allow(MessagingService).to receive(:send_reset_email)
      get :reset_password, params: {email: Base64.urlsafe_encode64(user.email)}
      expect(response.successful?).to be true
      expect(MessagingService).to have_received(:send_reset_email)
    end
    it "should confirm reset" do
      token = user.gen_pass_reset_token
      old_digest = user.password_digest
      new_pass = "password"
      put :confirm_reset, params: { token: token, password: new_pass }
      expect(response.successful?).to be true
      user.reload
      expect(user.password_digest).to_not eql old_digest
    end
    it "should not accept incorrect tokens" do
      other_user = FactoryBot.create(:student)
      token = other_user.gen_pass_reset_token * 2
      old_digest = user.password_digest
      new_pass = "password"
      put :confirm_reset, params: { token: token, password: new_pass }, format: :json
      expect(response).to be_unprocessable
      user.reload
      expect(user.password_digest).to eql old_digest
    end
  end

  context '.verify' do
    let(:user) { FactoryBot.create(:teacher, verified: false) }
    it 'accepts verification token' do
      token = user.gen_email_verification_token
      put :verify, params: { token: token}
      user.reload
      expect(user.verified).to be true
    end
    it 'rejects invalid tokens' do
      token = FactoryBot.create(:teacher).gen_email_verification_token
      put :verify, params: {token: token}
      user.reload
      expect(user.verified).to be false
    end
  end

  context ".destroy" do
    let(:teacher) { FactoryBot.create(:teacher) }
    let(:student) { FactoryBot.create(:student) }
    let(:admin) { FactoryBot.create(:super_user) }
    it "disallow student from deleting an account" do
      set_token student.token
      expect do
        delete :destroy, params: {id: student.id}
      end.to change(User, :count).by(0)
      expect(response).to be_forbidden
    end
    it "disallow a teacher from deleting an account" do
      set_token teacher.token
      expect do
        delete :destroy, params: {id: teacher.id}
      end.to change(User, :count).by(0)
      expect(response).to be_forbidden
    end

    it "allows an admin to delete a student" do
      student
      set_token admin.token
      expect do
        delete :destroy, params: {id: student.id}
      end.to change(User, :count).by(-1)
      expect(response.successful?).to be true
    end
    it "allows an admin to delete a teacher" do
      teacher
      set_token admin.token
      expect do
        delete :destroy, params: {id: teacher.id}
      end.to change(User, :count).by(-1)
      expect(response.successful?).to be true
    end
  end
end
