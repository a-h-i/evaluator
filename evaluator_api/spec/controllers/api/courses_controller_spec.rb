require "rails_helper"

RSpec.describe Api::CoursesController, type: :controller do
  context ".index" do
    let(:student) { FactoryBot.create(:student) }
    let(:teacher) { FactoryBot.create(:teacher) }
    let(:courses) { FactoryBot.create_list(:course, 5) }
    it "disallow unauthorized index" do
      get :index, format: :json
      expect(response).to be_unauthorized
    end
    it "allow a student to index" do
      set_token student.token
      get :index, format: :json
      expect(response).to be_success
      expect(json_response).to include(
        :courses, :page, :page_size, :total_pages
      )
    end
    it "allow a teacher to index" do
      set_token teacher.token
      get :index, format: :json
      expect(response).to be_success
    end
    it "has pagination" do
      set_token student.token
      get :index, format: :json, params: {page: 1, page_size: courses.length}
      expect(json_response).to include(
        :courses, :page, :page_size, :total_pages
      )
    end
    it "does not return unpublished courses to students" do
      courses
      set_token student.token
      get :index, format: :json
      expect(json_response[:page_size]).to eql 0
    end
    context "query" do
      it "overrides published param for students" do
        set_token student.token
        get :index, format: :json, params: { published: false }
        expect(json_response[:page_size]).to eql 0
      end

      it "queries by published" do
        course = FactoryBot.create(:course, published: true)
        set_token teacher.token
        get :index, format: :json, params: { published: true }
        expect(json_response[:page_size]).to eql 1
        expect(json_response[:courses].first[:id]).to eql course.id
      end
      it "queries by name" do
        course = FactoryBot.create(:course, published: true)
        set_token student.token
        get :index, format: :json, params: {name: course.name}
        expect(json_response[:page_size]).to eql 1
        expect(json_response[:courses].first[:id]).to eql course.id
      end
    end
  end

  context ".show" do
    let(:student) { FactoryBot.create(:student) }
    let(:teacher) { FactoryBot.create(:teacher) }
    let(:course) { FactoryBot.create(:course) }
    let(:published_course) { FactoryBot.create(:course, published: true) }
    it "disallows unauthorized show" do
      get :show, format: :json, params: {id: course.id}
      expect(response).to be_unauthorized
    end
    it "allows a teacher" do
      set_token teacher.token
      get :show, format: :json, params: {id: course.id}
      expect(json_response[:id]).to eql course.id
      expect(json_response).to include(
        :id, :name, :description, :published
      )
    end
    it "allows a student" do
      set_token student.token
      get :show, format: :json, params: {id: published_course.id}
      expect(json_response[:id]).to eql published_course.id
      expect(json_response).to include(
        :id, :name, :description, :published
      )
    end
    it "disallows a student to request an unpublished course" do
      set_token student.token
      get :show, format: :json, params: {id: course.id}
      expect(response).to be_forbidden
    end
  end

  context ".create" do
    let(:course_params) { FactoryBot.attributes_for(:course) }
    let(:teacher) { FactoryBot.create(:teacher) }
    let(:admin) { FactoryBot.create(:super_user) }
    it "disallows unauthorized" do
      expect do
        post :create, format: :json, params: course_params
      end.to change(Course, :count).by 0
      expect(response).to be_unauthorized
    end
    it "disallows students" do
      student = FactoryBot.create(:student)
      expect do
        set_token student.token
        post :create, format: :json, params: course_params
      end.to change(Course, :count).by 0
      expect(response).to be_forbidden
    end
    it "disallows teachers" do
      expect do
        set_token teacher.token
        post :create, format: :json, params: course_params
      end.to change(Course, :count).by 0
      expect(response).to be_forbidden
    end
    it "allows admin" do
      expect do
        set_token admin.token
        post :create, format: :json, params: course_params
      end.to change(Course, :count).by 1
      expect(response).to be_created
    end

    it "is unpublished by default" do
      set_token admin.token
      post :create, format: :json, params: course_params
      expect(json_response[:published]).to be false
    end

    it "allows setting of published field" do
      set_token admin.token
      course_params[:published] = true
      post :create, format: :json, params: course_params
      expect(json_response[:published]).to be true
    end
  end

  context ".update" do
    let(:course) { FactoryBot.create(:course) }
    let(:teacher) { FactoryBot.create(:teacher) }
    let(:admin) { FactoryBot.create(:super_user) }
    it "disallows unauthorized" do
      course.reload
      old_json = course.as_json
      put :update, format: :json, params: {name: "new course name!", id: course.id}
      expect(response).to be_unauthorized
      course.reload
      expect(course.as_json).to match old_json
    end

    it "disallows student" do
      course.reload
      old_json = course.as_json
      student = FactoryBot.create(:student)
      set_token student.token
      put :update, format: :json, params: {name: "new course name!", id: course.id}
      expect(response).to be_forbidden
      course.reload
      expect(course.as_json).to match old_json
    end
    it "disallows teacher" do
      course.reload
      old_json = course.as_json
      set_token teacher.token
      put :update, format: :json, params: {published: true, id: course.id}
      expect(response).to be_forbidden
      course.reload
      expect(course.as_json).to match old_json
    end

    it "allows admin" do
      course.reload
      old_json = course.as_json
      set_token admin.token
      put :update, format: :json, params: {published: true, id: course.id}
      expect(response).to be_success
      course.reload
      expect(course.as_json).to_not match old_json
    end
  end
  context ".destroy" do
    let(:student) { FactoryBot.create(:student) }
    let(:teacher) { FactoryBot.create(:teacher) }
    let(:admin) { FactoryBot.create(:super_user) }
    let(:course) { FactoryBot.create(:course) }
    it "disallows unauthorized" do
      course
      expect do
        delete :destroy, format: :json, params: {id: course.id}
      end.to change(Course, :count).by 0
      expect(response).to be_unauthorized
    end
    it "disallows a student" do
      course
      expect do
        set_token student.token
        delete :destroy, format: :json, params: {id: course.id}
      end.to change(Course, :count).by 0
      expect(response).to be_forbidden
    end
    it "disallows a teacher" do
      course
      expect do
        set_token teacher.token
        delete :destroy, format: :json, params: {id: course.id}
      end.to change(Course, :count).by 0
      expect(response).to be_forbidden
    end
    it "allows an admin" do
      course
      expect do
        set_token admin.token
        delete :destroy, format: :json, params: {id: course.id}
      end.to change(Course, :count).by(-1)
    end
  end
  context ".register" do
    let(:student) { FactoryBot.create(:student) }
    let(:teacher) { FactoryBot.create(:teacher) }
    let(:course) { FactoryBot.create(:course) }
    let(:published_course) { FactoryBot.create(:course, published: true) }
    it "disallows unauthorized" do
      expect do
        post :register, format: :json, params: { id: published_course.id }
      end.to change(StudentCourseRegistration, :count).by 0
      expect(response).to be_unauthorized
    end
    it "disallows registration to unpublished course" do
      expect do
        set_token student.token
        post :register, format: :json, params: { id: course.id }
      end.to change(StudentCourseRegistration, :count).by 0
      expect(response).to be_forbidden
    end
    it "disallows registration by teacher" do
      expect do
        set_token teacher.token
        post :register, format: :json, params: { id: published_course.id }
      end.to change(StudentCourseRegistration, :count).by 0
      expect(response).to be_forbidden
    end

    it "allows registration by student" do
      expect do
        set_token student.token
        post :register, format: :json, params: { id: published_course.id }
      end.to change(StudentCourseRegistration, :count).by 1
      expect(response).to be_created
    end
  end
  context '.unregister' do
    let(:student) { FactoryBot.create(:student) }
    let(:teacher) { FactoryBot.create(:teacher) }
    let(:course) { FactoryBot.create(:course) }
    let(:published_course) { FactoryBot.create(:course, published: true) }
    it 'disallows unauthorized' do
      expect do
        delete :unregister, format: :json, params: { id: published_course.id }
      end.to change(StudentCourseRegistration, :count).by 0
      expect(response).to be_unauthorized
    end
    it 'disallows unregistration to unpublished course' do
      expect do
        set_token student.token
        delete :unregister, format: :json, params: { id: course.id }
      end.to change(StudentCourseRegistration, :count).by 0
      expect(response).to be_forbidden
    end
    it 'disallows unregistration by teacher' do
      expect do
        set_token teacher.token
        delete :unregister, format: :json, params: { id: published_course.id }
      end.to change(StudentCourseRegistration, :count).by 0
      expect(response).to be_forbidden
    end

    it 'allows unregistration by student' do
      published_course.register student
      expect do
        set_token student.token
        delete :unregister, format: :json, params: { id: published_course.id }
      end.to change(StudentCourseRegistration, :count).by -1
      expect(response).to be_success
    end
  end
end
