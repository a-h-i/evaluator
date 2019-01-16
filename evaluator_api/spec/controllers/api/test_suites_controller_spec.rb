require 'rails_helper'

RSpec.describe Api::TestSuitesController, type: :controller do
  let(:published_course) { FactoryGirl.create(:course, published: true) }
  let(:published_project) { FactoryGirl.create(:project, course: published_course, published: true) }
  let(:unpublished_project) { FactoryGirl.create(:project, course: published_course, published: false) }
  let(:student) { FactoryGirl.create(:student) }
  let(:teacher) { FactoryGirl.create(:teacher) }
  let(:admin) { FactoryGirl.create(:super_user) }

  before :each do
    @create_suite = lambda do |project, hidden = false|
      suite = FactoryGirl.create(:test_suite, project: project, hidden: hidden)
      code = FactoryGirl.build(:suite_code)
      code.test_suite = suite
      code.save!
      suite.suite_code = code
      suite.save!
      return suite
    end
  end
  context 'create' do
    before :each do
      @file = fixture_file_upload('/files/test_suites/csv_test_suite.zip', 'application/zip', true)
    end
    it 'does not allow unauthorized' do
      expect do
        post :create, project_id: unpublished_project.id, file: @file
      end.to change(TestSuite, :count).by(0).and change(SuiteCode, :count).by(0)
      expect(response).to be_unauthorized
    end
    it 'does not allow student' do
      expect do
        set_token student.token
        post :create, project_id: unpublished_project.id, file: @file
      end.to change(TestSuite, :count).by(0).and change(SuiteCode, :count).by(0)
      expect(response).to be_forbidden
    end

    it 'does not allow teacher' do
      expect do
        set_token teacher.token
        post :create, project_id: unpublished_project.id, file: @file
      end.to change(TestSuite, :count).by(0).and change(SuiteCode, :count).by(0)
      expect(response).to be_forbidden
    end

    it 'allows admin' do
      expect do
        set_token admin.token
        post :create, project_id: unpublished_project.id, file: @file
      end.to change(TestSuite, :count).by(1).and change(SuiteCode, :count).by(1)
      expect(response).to be_created
    end

    it 'can not add to published project' do
      expect do
        set_token admin.token
        post :create, project_id: published_project.id, file: @file
      end.to change(TestSuite, :count).by(0).and change(SuiteCode, :count).by(0)
      expect(response).to be_forbidden
    end

    it 'queues suite process job' do
      expect(SuitesProcessJob).to receive(:perform_later).once
      set_token admin.token
      post :create, project_id: unpublished_project.id, file: @file
    end
  end
  context 'index' do
    before :each do
      @published = @create_suite.call published_project
      @published_hidden = @create_suite.call published_project, true
      @unpublished = @create_suite.call unpublished_project
      @unpublished_hidden = @create_suite.call unpublished_project, true
    end

    it 'does not allow unauthorized' do
      get :index, project_id: published_project.id
      expect(response).to be_unauthorized
    end
    it 'does not allow a student to list unpublished project suites' do
      set_token student.token
      get :index, project_id: unpublished_project.id
      expect(response).to be_forbidden
    end

    it 'allows a teacher to list unpublished project suites' do
      set_token teacher.token
      get :index, project_id: unpublished_project.id
      expect(response).to be_success
      expect(json_response[:test_suites].size).to eql 2
    end

    it 'allows a teacher to list published project suites' do
      set_token teacher.token
      get :index, project_id: published_project.id
      expect(response).to be_success
      expect(json_response[:test_suites].size).to eql 2
    end

    it 'allows a student to list published project suites' do
      set_token student.token
      get :index, project_id: published_project.id
      expect(response).to be_success
      expect(json_response[:test_suites].size).to eql 2
    end

    it 'has pagination' do
      set_token student.token
      get :index, project_id: published_project.id
      expect(json_response).to include(
        :test_suites, :page, :page_size, :total_pages
      )
    end
  end
  context 'show' do
    before :each do
      @published = @create_suite.call published_project
      @published_hidden = @create_suite.call published_project, true
      @unpublished = @create_suite.call unpublished_project
      @unpublished_hidden = @create_suite.call unpublished_project, true
    end

    it 'does not allow unauthorized' do
      get :show, id: @published.id
      expect(response).to be_unauthorized
    end

    it 'student can view non hidden published' do
      set_token student.token
      get :show, id: @published.id
      expect(response).to be_success
    end

    it 'student can not view hidden published' do
      set_token student.token
      get :show, id: @published_hidden.id
      expect(response).to be_forbidden
    end
    it 'student can not view unpublished not hidden' do
      set_token student.token
      get :show, id: @unpublished
      expect(response).to be_forbidden
    end
    it 'student can not view unpublished hidden' do
      set_token student.token
      get :show, id: @unpublished_hidden
      expect(response).to be_forbidden
    end

    it 'teacher can view non hidden published' do
      set_token teacher.token
      get :show, id: @published.id
      expect(response).to be_success
    end

    it 'teacher can view hidden published' do
      set_token teacher.token
      get :show, id: @published_hidden.id
      expect(response).to be_success
    end

    it 'teacher can view unpublished not hidden' do
      set_token teacher.token
      get :show, id: @unpublished.id
      expect(response).to be_success
    end

    it 'teacher can view unpublished hidden' do
      set_token teacher.token
      get :show, id: @unpublished_hidden.id
      expect(response).to be_success
    end
  end
  context 'download' do
    before :each do
      @published = @create_suite.call published_project
      @published_hidden = @create_suite.call published_project, true
      @unpublished = @create_suite.call unpublished_project
      @unpublished_hidden = @create_suite.call unpublished_project, true
    end
    it 'does not allow unauthorized' do
      get :download, id: @published.id
      expect(response).to be_unauthorized
    end

    it 'student can download non hidden published' do
      set_token student.token
      get :download, id: @published.id
      expect(response).to be_success
    end

    it 'student can not download hidden published' do
      set_token student.token
      get :download, id: @published_hidden.id
      expect(response).to be_forbidden
    end
    it 'student can not download unpublished not hidden' do
      set_token student.token
      get :download, id: @unpublished
      expect(response).to be_forbidden
    end
    it 'student can not download unpublished hidden' do
      set_token student.token
      get :download, id: @unpublished_hidden
      expect(response).to be_forbidden
    end

    it 'teacher can download non hidden published' do
      set_token teacher.token
      get :download, id: @published.id
      expect(response).to be_success
    end

    it 'teacher can download hidden published' do
      set_token teacher.token
      get :download, id: @published_hidden.id
      expect(response).to be_success
    end

    it 'teacher can download unpublished not hidden' do
      set_token teacher.token
      get :download, id: @unpublished.id
      expect(response).to be_success
    end

    it 'teacher can download unpublished hidden' do
      set_token teacher.token
      get :download, id: @unpublished_hidden.id
      expect(response).to be_success
    end
  end
  context 'destroy' do
    before :each do
      @published = @create_suite.call published_project
      @unpublished = @create_suite.call unpublished_project
      @unpublished.ready = true
      @unpublished.save!
    end
    it 'does not allow unauthorized' do
      expect do
        delete :destroy, id: @unpublished.id
      end.to change(TestSuite, :count).by 0
      expect(response).to be_unauthorized
    end

    it 'does not allow student' do
      set_token student.token
      expect do
        delete :destroy, id: @unpublished.id
      end.to change(TestSuite, :count).by 0
      expect(response).to be_forbidden
    end

    it 'does not allow teacher' do
      expect do
        set_token teacher.token
        delete :destroy, id: @unpublished.id
      end.to change(TestSuite, :count).by(0)
        .and change(SuiteCode, :count).by(0)
      expect(response).to be_forbidden
    end

    it 'allows admin' do
      expect do
        set_token admin.token
        delete :destroy, id: @unpublished.id
      end.to change(TestSuite, :count).by(-1)
        .and change(SuiteCode, :count).by(-1)
      expect(response).to be_success
    end

    it 'queues a job' do
      expect(DestroyTestSuiteJob).to receive(:perform_later).once
      set_token admin.token
      delete :destroy, id: @unpublished.id
    end

    it 'can not destroy belonging to published project' do
      expect do
        set_token admin.token
        delete :destroy, id: @published.id
      end.to change(TestSuite, :count).by(0)
        .and change(SuiteCode, :count).by(0)
      expect(response).to be_forbidden
    end
  end
end
