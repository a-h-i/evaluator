require 'rails_helper'

RSpec.describe Api::ResultsController, type: :controller do
  before :each do
    @project = FactoryGirl.create(:project, published: true,
                                            course: FactoryGirl.create(:course, published: true))
    @create_result = lambda do |team_name, submitter = nil|
      submitter ||= FactoryGirl.create(:student, verified: true, team: team_name)
      submission = FactoryGirl.create(:submission, submitter: submitter,
                                                   project: @project)
      FactoryGirl.create(:result, project: @project, submission: submission)
    end
    @default_team = 'Default__Results_Controller_SPEC_TEAM'
  end
  context 'index' do
    let(:teacher) { FactoryGirl.create(:teacher) }
    before :each do
      2.times { @create_result.call @default_team }
      @other_team = 'OTHER_TEAM_Results_Controller_SPEC_TEAM'
      4.times { @create_result.call @other_team }
    end
    it 'does not allow unauthorized' do
      get :index, format: :json, project_id: @project.id
      expect(response).to be_unauthorized
    end
    it '404s on unknown parent' do
      set_token teacher.token
      get :index, format: :json, project_id: 'unknown'
      expect(response).to be_not_found
    end
    it 'allows a teacher' do
      set_token teacher.token
      get :index, format: :json, project_id: @project.id
      expect(response).to be_success
      expect(json_response[:results].size).to eql 6
    end
    it 'does not allow a student by team' do
      student = FactoryGirl.create(:student, verified: true, team: @default_team)
      set_token student.token
      get :index, format: :json, project_id: @project.id
      expect(response).to be_success
      expect(json_response[:results].size).to eql 0
    end

    it 'allows a student' do
      student = FactoryGirl.create(:student, verified: true, team: @default_team)
      @create_result.call(@default_team, student)
      set_token student.token
      get :index, format: :json, project_id: @project.id
      expect(response).to be_success
      expect(json_response[:results].size).to eql 1
    end

    it 'can query by team_name' do
      set_token teacher.token
      get :index, format: :json, project_id: @project.id, submitter: { team: @default_team }
      expect(response).to be_success
      expect(json_response[:results].size).to eql 2
    end
  end

  context 'show' do
    let(:teacher) { FactoryGirl.create(:teacher) }
    before :each do
      @default_result = @create_result.call @default_team
      @other_team = 'OTHER_TEAM_Results_Controller_SPEC_TEAM'
      @other_result = @create_result.call @other_team
    end

    it 'teacher can view any result' do
      set_token teacher.token
      get :show, format: :json, id: @default_result.id
      expect(response).to be_success
      expect(json_response[:id]).to eql @default_result.id
      get :show, format: :json, id: @other_result.id
      expect(response).to be_success
      expect(json_response[:id]).to eql @other_result.id
    end

    it 'student can view own result' do
      student = FactoryGirl.create(:student, verified: true, team: @default_team)
      result = @create_result.call @default_team, student
      set_token student.token
      get :show, format: :json, id: result.id
      expect(response).to be_success
    end
    it 'student can not view team belonging result' do
      student = FactoryGirl.create(:student, verified: true, team: @default_team)
      set_token student.token
      get :show, format: :json, id: @default_result.id
      expect(response).to be_forbidden
    end
    it 'student can not view result belonging to another team' do
      student = FactoryGirl.create(:student, verified: true, team: @default_team)
      set_token student.token
      get :show, format: :json, id: @other_result.id
      expect(response).to be_forbidden
    end
    it 'does not allow unauthorized' do
      get :show, format: :json, id: @default_result.id
      expect(response).to be_unauthorized
    end
  end

  context 'csv' do
    it 'does not allow unauthorized' do
      get :csv, project_id: @project.id
      expect(response).to be_unauthorized
    end
    it 'does not allow student' do
      student = FactoryGirl.create(:student, verified: true)
      set_token student.token
      get :csv, project_id: @project.id
      expect(response).to be_forbidden
    end
    it 'allows teacher' do

      teacher = FactoryGirl.create(:teacher, verified: true)
      set_token teacher.token
      get :csv, project_id: @project.id
      expect(response).to be_success
    end

    it 'allows teams only filter' do
      10.times { @create_result.call 'one'}
      10.times { @create_result.call 'two' }
      teacher = FactoryGirl.create(:teacher, verified: true)
      set_token teacher.token
      get :csv, project_id: @project.id, teams_only: true
      expect(response).to be_success
    end
  end

  context 'update' do
    it 'is not routable' do
      expect(put: 'api/results/3').to_not be_routable
      expect(patch: 'api/results/3').to_not be_routable
    end
  end
  context 'destroy' do
    it 'is not routable' do
      expect(delete: '/api/results/3').to_not be_routable
    end
  end
  context 'create' do
    it 'is not routable' do
      expect(post: '/api/projects/3/results').to_not be_routable
    end
  end
end
