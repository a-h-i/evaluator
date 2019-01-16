require 'rails_helper'

RSpec.describe Api::CoursesController, type: :controller do

  context '.index' do
    let(:student) { FactoryGirl.create(:student) }
    let(:teacher) { FactoryGirl.create(:teacher) }
    let(:courses) { FactoryGirl.create_list(:course, 5) }
    it 'disallow unauthorized index' do
      get :index, format: :json
      expect(response).to be_unauthorized
    end
    it 'allow a student to index' do
      set_token student.token
      get :index, format: :json
      expect(response).to be_success
    end
    it 'allow a teacher to index' do
      set_token teacher.token
      get :index, format: :json
      expect(response).to be_success
    end
    it 'have pagination' do
      set_token student.token
      get :index, format: :json, page: 1, page_size: courses.length
      expect(json_response).to include(
        :courses, :page, :page_size, :total_pages
      )
    end
    it 'not return unpublished courses to students' do
      courses
      set_token student.token
      get :index, format: :json
      expect(json_response[:page_size]).to eql 0
    end
    context 'query' do
      it 'override published param for students' do
        set_token student.token
        get :index, format: :json, published: false
        expect(json_response[:page_size]).to eql 0
      end

      it 'query by published' do
        course = FactoryGirl.create(:course, published: true)
        set_token teacher.token
        get :index, format: :json, published: true
        expect(json_response[:page_size]).to eql 1
        expect(json_response[:courses].first[:id]).to eql course.id
      end
      it 'query by name' do
        course = FactoryGirl.create(:course, published: true)
        set_token student.token
        get :index, format: :json, name: course.name
        expect(json_response[:page_size]).to eql 1
        expect(json_response[:courses].first[:id]).to eql course.id
      end
    end
  end
  context '.show' do
    let(:student) { FactoryGirl.create(:student) }
    let(:teacher) { FactoryGirl.create(:teacher) }
    let(:course) { FactoryGirl.create(:course) }
    let(:published_course) { FactoryGirl.create(:course, published: true) }
    it 'disallow unauthorized show' do
      get :show, format: :json, id: course.id
      expect(response).to be_unauthorized
    end
    it 'allow a teacher' do
      set_token teacher.token
      get :show, format: :json, id: course.id
      expect(json_response[:id]).to eql course.id
      expect(json_response).to include(
        :id, :name, :description, :published
      )
    end
    it 'allow a student' do
      set_token student.token
      get :show, format: :json, id: published_course.id
      expect(json_response[:id]).to eql published_course.id
      expect(json_response).to include(
        :id, :name, :description, :published
      )
    end
    it 'disallow a student to request an unpublished course' do
      set_token student.token
      get :show, format: :json, id: course.id
      expect(response).to be_forbidden
    end
  end

  context '.create' do
    let(:course_params) { FactoryGirl.attributes_for(:course) }
    let(:teacher) { FactoryGirl.create(:teacher) }
    let(:admin) { FactoryGirl.create(:super_user) }
    it 'disallow unauthorized' do
      expect do
        post :create, format: :json, **course_params
      end.to change(Course, :count).by 0
      expect(response).to be_unauthorized
    end
    it 'disallow students' do
      student = FactoryGirl.create(:student)
      expect do
        set_token student.token
        post :create, format: :json, **course_params
      end.to change(Course, :count).by 0
      expect(response).to be_forbidden
    end
    it 'disallow teachers' do
      expect do
        set_token teacher.token
        post :create, format: :json, **course_params
      end.to change(Course, :count).by 0
      expect(response).to be_forbidden
    end

    it 'allows admin' do
      expect do
        set_token admin.token
        post :create, format: :json, **course_params
      end.to change(Course, :count).by 1
      expect(response).to be_created
    end

    it 'be unpublished by default' do
      set_token admin.token
      post :create, format: :json, **course_params
      expect(json_response[:published]).to be false
    end

    it 'allow setting of published field' do
      set_token admin.token
      course_params[:published] = true
      post :create, format: :json, **course_params
      expect(json_response[:published]).to be true
    end
  end

  context '.update' do
    let(:course) { FactoryGirl.create(:course) }
    let(:teacher) { FactoryGirl.create(:teacher) }
    let(:admin) { FactoryGirl.create(:super_user) }
    it 'disallow unauthorized' do
      course.reload
      old_json = course.as_json
      put :update, id: course.id, format: :json, name: 'new course name!'
      expect(response).to be_unauthorized
      course.reload
      expect(course.as_json).to match old_json
    end

    it 'disallow student' do
      course.reload
      old_json = course.as_json
      student = FactoryGirl.create(:student)
      set_token student.token
      put :update, id: course.id, format: :json, name: 'new course name!'
      expect(response).to be_forbidden
      course.reload
      expect(course.as_json).to match old_json
    end

    it 'disallow teacher' do
      course.reload
      old_json = course.as_json
      set_token teacher.token
      put :update, id: course.id, format: :json, published: true
      expect(response).to be_forbidden
      course.reload
      expect(course.as_json).to match old_json
    end

    it 'allows admin' do
      course.reload
      old_json = course.as_json
      set_token admin.token
      put :update, id: course.id, format: :json, published: true
      expect(response).to be_success
      course.reload
      expect(course.as_json).to_not match old_json
    end
  end

  context '.destroy' do
    let(:student) { FactoryGirl.create(:student) }
    let(:teacher) { FactoryGirl.create(:teacher) }
    let(:admin) { FactoryGirl.create(:super_user) }
    let(:course) { FactoryGirl.create(:course) }

    it 'disallow unauthorized' do
      course
      expect do
        delete :destroy, format: :json, id: course.id
      end.to change(Course, :count).by 0
      expect(response).to be_unauthorized
    end
    it 'disallow a student' do
      course
      expect do
        set_token student.token
        delete :destroy, format: :json, id: course.id
      end.to change(Course, :count).by 0
      expect(response).to be_forbidden
    end
    it 'disallow a teacher' do
      course
      expect do
        set_token teacher.token
        delete :destroy, format: :json, id: course.id
      end.to change(Course, :count).by 0
      expect(response).to be_forbidden
    end
    it 'allows an admin' do
      course
      expect do
        set_token admin.token
        delete :destroy, format: :json, id: course.id
      end.to change(Course, :count).by(-1)
    end
  end

  context '.register' do
    let(:student) { FactoryGirl.create(:student) }
    let(:teacher) { FactoryGirl.create(:teacher) }
    let(:course) { FactoryGirl.create(:course) }
    let(:published_course) { FactoryGirl.create(:course, published: true) }
    it 'disallow unauthorized' do
      expect do
        post :register, format: :json, id: published_course.id
      end.to change(Studentship, :count).by 0
      expect(response).to be_unauthorized
    end
    it 'disallow registration to unpublished course' do
      expect do
        set_token student.token
        post :register, format: :json, id: course.id
      end.to change(Studentship, :count).by 0
      expect(response).to be_forbidden
    end
    it 'disallow registration by teacher' do
      expect do
        set_token teacher.token
        post :register, format: :json, id: published_course.id
      end.to change(Studentship, :count).by 0
      expect(response).to be_forbidden
    end

    it 'allow registration by student' do
      expect do
        set_token student.token
        post :register, format: :json, id: published_course.id
      end.to change(Studentship, :count).by 1
      expect(response).to be_created
    end
  end

  context '.unregister' do
    let(:student) { FactoryGirl.create(:student) }
    let(:teacher) { FactoryGirl.create(:teacher) }
    let(:course) { FactoryGirl.create(:course) }
    let(:published_course) { FactoryGirl.create(:course, published: true) }
    it 'allow unauthorized' do
      expect do
        delete :unregister, format: :json, id: published_course.id
      end.to change(Studentship, :count).by 0
      expect(response).to be_unauthorized
    end
    it 'allow unregistration to unpublished course' do
      expect do
        set_token student.token
        delete :unregister, format: :json, id: course.id
      end.to change(Studentship, :count).by 0
      expect(response).to be_forbidden
    end
    it 'allow unregistration by teacher' do
      expect do
        set_token teacher.token
        delete :unregister, format: :json, id: published_course.id
      end.to change(Studentship, :count).by 0
      expect(response).to be_forbidden
    end

    it 'allow unregistration by student' do
      published_course.register student
      expect do
        set_token student.token
        delete :unregister, format: :json, id: published_course.id
      end.to change(Studentship, :count).by -1
      expect(response).to be_success
    end
  end
end
