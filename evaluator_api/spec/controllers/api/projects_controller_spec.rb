require 'rails_helper'

RSpec.describe Api::ProjectsController, type: :controller do
  let(:student) { FactoryBot.create(:student) }
  let(:unpublished_course) { FactoryBot.create(:course) }
  let(:published_course) { FactoryBot.create(:course, published: true) }
  let(:teacher) { FactoryBot.create(:teacher) }
  let(:admin) { FactoryBot.create(:super_user) }

  context ".index" do
    let(:projects) { FactoryBot.create_list(:project, 3, course: published_course) }
    let(:published_projects) { FactoryBot.create_list(:project, 2, course: published_course, published: true) }
    it 'disallow unauthorized' do
      get :index, format: :json, params: {course_id: published_course.id}
      expect(response).to be_unauthorized
    end
    it 'allows a student to index' do
      set_token student.token
      get :index, format: :json, params: {course_id: published_course.id}
      expect(response.successful?).to be true
    end
    it 'allows a teacher to index' do
      set_token teacher.token
      get :index, format: :json, params: {course_id: published_course.id}
      expect(response.successful?).to be true
    end
    it 'allows an admin to index' do
      set_token admin.token
      get :index, format: :json, params: {course_id: published_course.id}
      expect(response.successful?).to be true
    end
    it 'have pagination' do
      set_token teacher.token
      get :index, format: :json, params: {course_id: published_course.id}
      expect(json_response).to include(
        :projects, :page, :page_size, :total_pages
      )
    end
    it 'not return unpublished projects to students' do
      projects
      set_token student.token
      get :index, format: :json, params: {course_id: published_course.id}
      expect(json_response[:page_size]).to eql 0
    end
    it 'disallows a student to index projects of an unpublished course' do
      projects = FactoryBot.create(:project, course: unpublished_course)
      set_token student.token
      get :index, format: :json, params: {course_id: unpublished_course.id}
      expect(json_response).to_not include(:projects)
      expect(response).to be_forbidden
    end
    it 'allows a teacher to index projects of an unpublished course' do
      projects = FactoryBot.create(:project, course: unpublished_course)
      set_token teacher.token
      get :index, format: :json, params: {course_id: unpublished_course.id}
      expect(json_response).to include(:projects)
      expect(response.successful?).to be true
    end
    it 'allows an admin to index projects of a published course' do
      projects = FactoryBot.create(:project, course: unpublished_course)
      set_token admin.token
      get :index, format: :json, params: {course_id: unpublished_course.id}
      expect(json_response).to include(:projects)
      expect(response.successful?).to be true
    end
    context 'query' do
      context 'due' do
        let(:due_project) { FactoryBot.create(:project, course: published_course, due_date: 5.days.ago, published: true) }
        let(:not_due_project) { FactoryBot.create(:project, course: published_course, published: true, due_date: 5.days.from_now) }
        it 'due only' do
          set_token student.token
          not_due_project # Force creation
          not_due_project.course.register student
          get :index, format: :json, params: { course_id: due_project.course.id, due: true}
          expect(json_response[:projects].size).to eql 1
          expect(json_response[:projects].first[:id]).to eql due_project.id
        end
        it 'not due only' do
          set_token student.token
          due_project # Force creation
          due_project.course.register student
          get :index, format: :json, params: {course_id: not_due_project.course.id, due: false}
          expect(json_response[:projects].size).to eql 1
          expect(json_response[:projects].first[:id]).to eql not_due_project.id
        end
      end
      it 'overrides published param for students' do
        projects
        set_token student.token
        get :index, format: :json, params: {course_id: published_course.id, published: false}
        expect(json_response[:page_size]).to eql 0
      end
      it 'filters by published' do
        published_projects
        projects
        set_token teacher.token
        get :index, format: :json, params: {course_id: published_course.id, published: true}
        expect(json_response[:page_size]).to eql published_projects.size
      end
      it 'does not set default published param for teachers' do
        projects
        set_token teacher.token
        get :index, format: :json, params: {course_id: published_course.id}
        expect(json_response[:page_size]).to eql projects.size
      end
      it 'does not set default published param for admins' do
        projects
        set_token admin.token
        get :index, format: :json, params: {course_id: published_course.id}
        expect(json_response[:page_size]).to eql projects.size
      end
      it 'filters by name' do
        project = FactoryBot.create(:project, course: published_course, name: 'stupid name')
        set_token teacher.token
        get :index, format: :json, params: {course_id: published_course.id, name: project.name}
        expect(json_response[:page_size]).to eql 1
      end

      it 'filters by started' do
        project = FactoryBot.create(:project, course: published_course, start_date: 3.days.ago, published: true)
        FactoryBot.create(:project, course: published_course, start_date: 5.days.from_now, published: true)
        published_course.register student
        set_token student.token
        get :index, format: :json, params: {course_id: published_course.id, started: true}
        expect(json_response[:page_size]).to eql 1
        expect(json_response[:projects].first[:id]).to eql project.id
      end
    end
  end

  context '.show' do
    let(:published_project_published_course) { FactoryBot.create(:project, course: published_course, published: true) }
    let(:unpublished_project_published_course) { FactoryBot.create(:project, course: published_course, published: false) }
    let(:published_project_unpublished_course) { FactoryBot.create(:project, course: unpublished_course, published: true) }
    let(:unpublished_project_unpublished_course) { FactoryBot.create(:project, course: unpublished_course, published: false) }
    it 'disallow unauthorized' do
      get :show, format: :json, params: {id: published_project_published_course.id}
      expect(response).to be_unauthorized
    end
    it 'disallow a student to view a published project of an unpublished course' do
      set_token student.token
      get :show, format: :json, params: {id: published_project_published_course.id}
      expect(response).to be_forbidden
    end
    it 'disallow a student to view an unpublished project of an unpublished course' do
      set_token student.token
      get :show, format: :json, params: {id: unpublished_project_unpublished_course.id}
      expect(response).to be_forbidden
    end

    it 'disallow a student to view an unpublished project of a published course' do
      set_token student.token
      get :show, format: :json, params: {id: unpublished_project_published_course.id}
      expect(response).to be_forbidden
    end

    it 'allow a teacher to view a published project of an unpublished course' do
      set_token teacher.token
      get :show, format: :json, params: {id: published_project_unpublished_course.id}
      expect(response.successful?).to be true
      expect(json_response[:id]).to eql published_project_unpublished_course.id
    end
    it 'allow a teacher to view an unpublished project of an unpublished course' do
      set_token teacher.token
      get :show, format: :json, params: {id: unpublished_project_unpublished_course.id}
      expect(response.successful?).to be true
      expect(json_response[:id]).to eql unpublished_project_unpublished_course.id
    end

    it 'allow a student to view a published project of a published course' do
      set_token student.token
      published_project_published_course.course.register(student)
      get :show, format: :json, params: {id: published_project_published_course.id}
      expect(response.successful?).to be true
      expect(json_response[:id]).to eql published_project_published_course.id
    end

    it 'allow teacher to view a published project of a published course' do
      set_token teacher.token
      get :show, format: :json, params: {id: published_project_published_course.id}
      expect(response.successful?).to be true
      expect(json_response[:id]).to eql published_project_published_course.id
    end

    it 'allow a teacher to view an unpublished project of a published course' do
      set_token teacher.token
      get :show, format: :json, params: {id: unpublished_project_published_course.id}
      expect(response.successful?).to be true
      expect(json_response[:id]).to eql unpublished_project_published_course.id
    end
  end
  context '.create' do
    let(:params) { FactoryBot.attributes_for(:project) }
    it 'disallows unauthorized' do
      expect do
        post :create, format: :json, params: params.merge({course_id: published_course.id})
      end.to change(Project, :count).by 0
      expect(response).to be_unauthorized
    end
    it 'disallows student' do
      expect do
        set_token student.token
        post :create, format: :json, params: params.merge({course_id: published_course.id})
      end.to change(Project, :count).by 0
      expect(response).to be_forbidden
    end
    it 'disallows teacher' do
      expect do
        set_token teacher.token
        post :create, format: :json, params: params.merge({course_id: published_course.id})
      end.to change(Project, :count).by 0
      expect(response).to be_forbidden
    end

    it 'allows an admin' do
      expect do
        set_token admin.token
        post :create, format: :json, params: params.merge({course_id: published_course.id})
      end.to change(Project, :count).by 1
      expect(response).to be_created
      expect(json_response[:course_id]).to eql published_course.id
    end
  end
  context '.update' do
    let(:project) { FactoryBot.create(:project, published: true, course: published_course) }

    it 'disallows unauthorized' do
      project.reload
      original = project.as_json
      put :update, format: :json, params: {id: project.id, quiz: true}
      expect(response).to be_unauthorized
      project.reload
      expect(original).to eql project.as_json
    end

    it 'disallows student' do
      project.reload
      set_token student.token
      original = project.as_json
      put :update, format: :json, params: {id: project.id, quiz: true}
      expect(response).to be_forbidden
      project.reload
      expect(original).to eql project.as_json
    end

    it 'disallows teacher' do
      project.reload
      set_token teacher.token
      original = project.as_json
      put :update, format: :json, params: {id: project.id, quiz: true}
      expect(response).to be_forbidden
      project.reload
      expect(original).to eql project.as_json
    end

    it 'allows admin' do
      project.reload
      set_token admin.token
      original = project.as_json
      put :update, format: :json, params: {id: project.id, quiz: true}
      expect(response.successful?).to be true
      project.reload
      expect(original).to_not eql project.as_json
    end
  end
  context '.destroy' do
    let(:project) { FactoryBot.create(:project, published: true, course: published_course) }
    it 'disallows unauthorized' do
      project
      expect do
        delete :destroy, format: :json, params: {id: project.id}
      end.to change(Project, :count).by 0
      expect(response).to be_unauthorized
      expect(Project.exists?(project.id)).to be true
    end

    it 'disallows student' do
      set_token student.token
      project
      expect do
        delete :destroy, format: :json,  params: {id: project.id}
      end.to change(Project, :count).by 0
      expect(response).to be_forbidden
      expect(Project.exists?(project.id)).to be true
    end

    it 'disallows teacher' do
      project
      expect do
        set_token teacher.token
        delete :destroy, format: :json,  params: {id: project.id}
      end.to change(Project, :count).by(0)
      expect(response).to be_forbidden
      expect(Project.exists?(project.id)).to be true
    end

    it 'allows admin' do
      project
      expect do
        set_token admin.token
        delete :destroy, format: :json,  params: {id: project.id}
      end.to change(Project, :count).by(-1)
      expect(response.successful?).to be true
      expect(Project.exists?(project.id)).to be false
    end
  end
end
