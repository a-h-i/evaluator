require "rails_helper"

RSpec.describe Api::TestSuitesController, type: :controller do
  let(:student) { FactoryBot.create(:student) }
  let(:teacher) { FactoryBot.create(:teacher) }
  let(:admin) { FactoryBot.create(:super_user) }
  let(:unpublished_course) { FactoryBot.create(:course) }
  let(:published_course) { FactoryBot.create(:course, published: true) }
  let(:published_project_published_course) { FactoryBot.create(:project, course: published_course, published: true) }
  let(:published_project_unpublished_course) { FactoryBot.create(:project, course: unpublished_course, published: true) }
  let(:unpublished_project_unpublished_course) { FactoryBot.create(:project, course: unpublished_course, published: false) }
  let(:unpublished_project_published_course) { FactoryBot.create(:project, course: published_course, published: false) }
  describe ".create" do
    let(:suite_params) { FactoryBot.attributes_for(:test_suite) }
    before :each do
      @file = fixture_file_upload("/files/test_suites/M1PrivateTest.zip", "application/zip", true)
    end

    context "published course" do
      context "published project" do
        before :each do
          @params = suite_params.merge({file: @file, project_id: published_project_published_course.id})
        end
        it "does not allow unauthorized" do
          expect do
            post :create, params: @params
          end.to change(TestSuite, :count).by(0)
          expect(response).to be_unauthorized
        end
        it "does not allow student" do
          expect do
            set_token student.token
            post :create, params: @params
          end.to change(TestSuite, :count).by(0)
          expect(response).to be_forbidden
        end
        it "does not allow teacher" do
          expect do
            set_token teacher.token
            post :create, params: @params
          end.to change(TestSuite, :count).by(0)
          expect(response).to be_forbidden
        end
        it "allows admin" do
          expect do
            set_token admin.token
            post :create, params: @params
          end.to change(TestSuite, :count).by(1)
          expect(response).to be_successful
        end
      end

      context "unpublished project" do
        before :each do
          @params = suite_params.merge({file: @file, project_id: unpublished_project_published_course.id})
        end
        it "does not allow unauthorized" do
          expect do
            post :create, params: @params
          end.to change(TestSuite, :count).by(0)
          expect(response).to be_unauthorized
        end
        it "does not allow student" do
          expect do
            set_token student.token
            post :create, params: @params
          end.to change(TestSuite, :count).by(0)
          expect(response).to be_forbidden
        end
        it "does not allow teacher" do
          expect do
            set_token teacher.token
            post :create, params: @params
          end.to change(TestSuite, :count).by(0)
          expect(response).to be_forbidden
        end
        it "allows admin" do
          expect do
            set_token admin.token
            post :create, params: @params
          end.to change(TestSuite, :count).by(1)
          expect(response).to be_successful
        end
      end
    end
    context "unpublished course" do
      context "unpublished project" do
        before :each do
          @params = suite_params.merge({file: @file, project_id: unpublished_project_unpublished_course.id})
        end
        it "does not allow unauthorized" do
          expect do
            post :create, params: @params
          end.to change(TestSuite, :count).by(0)
          expect(response).to be_unauthorized
        end
        it "does not allow student" do
          expect do
            set_token student.token
            post :create, params: @params
          end.to change(TestSuite, :count).by(0)
          expect(response).to be_forbidden
        end
        it "does not allow teacher" do
          expect do
            set_token teacher.token
            post :create, params: @params
          end.to change(TestSuite, :count).by(0)
          expect(response).to be_forbidden
        end
        it "allows admin" do
          expect do
            set_token admin.token
            post :create, params: @params
          end.to change(TestSuite, :count).by(1)
          expect(response).to be_successful
        end
      end
    end
  end

  describe ".destroy" do
    let(:test_suite) { FactoryBot.create(:test_suite, project: published_project_published_course) }

    it "does not allow unauthorized" do
      test_suite
      expect do
        delete :destroy, format: :json, params: {id: test_suite.id}
      end.to change(TestSuite, :count).by 0
      expect(response).to be_unauthorized
    end
    it "does not allow student" do
      test_suite
      expect do
        set_token student.token
        delete :destroy, format: :json, params: {id: test_suite.id}
      end.to change(TestSuite, :count).by 0
      expect(response).to be_forbidden
    end
    it "does not allow teacher" do
      test_suite
      expect do
        set_token teacher.token
        delete :destroy, format: :json, params: {id: test_suite.id}
      end.to change(TestSuite, :count).by 0
      expect(response).to be_forbidden
    end
    it "allows admin" do
      test_suite
      expect do
        set_token admin.token
        delete :destroy, format: :json, params: {id: test_suite.id}
      end.to change(TestSuite, :count).by -1
      expect(response).to be_successful
    end
  end

  describe ".show" do
    

    context 'private' do
      let(:suite) { FactoryBot.create(:test_suite, hidden: true) }
      it 'does not allow unauthorized' do
        get :show, params: {id: suite.id}
        expect(response).to be_unauthorized
      end
      it 'does not allow student' do
        set_token student.token
        get :show, params: {id: suite.id}
        expect(response).to be_forbidden
      end

      it 'allows teacher' do
        set_token teacher.token
        get :show, params: {id: suite.id}
        expect(response).to be_successful
      end
    end

    context 'public' do
      let(:suite) { FactoryBot.create(:test_suite, hidden: false) }
      it 'does not allow unauthorized' do
        get :show, params: {id: suite.id}
        expect(response).to be_unauthorized
      end
      it 'allows student' do
        set_token student.token
        get :show, params: {id: suite.id}
        expect(response).to be_successful
      end

      it 'allows teacher' do
        set_token teacher.token
        get :show, params: {id: suite.id}
        expect(response).to be_successful
      end
    end
  end

  describe '.download' do

    context 'private' do
      let(:suite) { FactoryBot.create(:test_suite, hidden: true) }
      it 'does not allow unauthorized' do
        get :download, params: {id: suite.id}
        expect(response).to be_unauthorized
      end
      it 'does not allow student' do
        set_token student.token
        get :download, params: {id: suite.id}
        expect(response).to be_forbidden
      end

      it 'allows teacher' do
        set_token teacher.token
        get :download, params: {id: suite.id}
        expect(response).to be_successful
      end
    end

    context 'public' do
      let(:suite) { FactoryBot.create(:test_suite, hidden: false) }
      it 'does not allow unauthorized' do
        get :download, params: {id: suite.id}
        expect(response).to be_unauthorized
      end
      it 'allows student' do
        set_token student.token
        get :download, params: {id: suite.id}
        expect(response).to be_successful
      end

      it 'allows teacher' do
        set_token teacher.token
        get :download, params: {id: suite.id}
        expect(response).to be_successful
      end
    end
  end

  describe '.index' do
    before :each do
      @num_priv = 1
      @num_public = 2
      @default_project = published_project_published_course
      @num_priv.times {FactoryBot.create(:test_suite, project: @default_project, hidden: true)}
      @num_public.times {FactoryBot.create(:test_suite, project: @default_project, hidden: false)}
    end

    it 'does not allow unauthorized' do
      get :index, params: {project_id: @default_project.id}
      expect(response).to be_unauthorized
    end
    it 'allows student to view public' do
      set_token student.token
      get :index, params: {project_id: @default_project.id}
      expect(response).to be_successful
      expect(json_response[:test_suites].size).to eql @num_public
    end
    it 'allows teacher to list public and private' do
      set_token teacher.token
      get :index, params: {project_id: @default_project.id}
      expect(response).to be_successful
      expect(json_response[:test_suites].size).to eql (@num_public + @num_priv)
    end
  end
end
