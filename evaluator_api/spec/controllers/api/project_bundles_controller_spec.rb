require 'rails_helper'

RSpec.describe Api::ProjectBundlesController, type: :controller do
  let(:project) { FactoryGirl.create(:project) }
  let(:teacher) { FactoryGirl.create(:teacher) }
  let(:student) { FactoryGirl.create(:student) }
  context '.create' do
    it 'does not allow unauthorized' do
      expect { post :create, project_id: project.id }.to change(ProjectBundle,
        :count).by(0)
      expect(response).to be_unauthorized
    end
    it 'does not allow student' do
      set_token student.token
      expect { post :create, project_id: project.id }.to change(ProjectBundle,
        :count).by(0)
      expect(response).to be_forbidden
    end
    it 'allows teacher' do
      expect(ProjectBundleJob).to receive(:perform_later)
      expect(ProjectTeamsBundleJob).to_not receive(:perform_later)
      expect do
        set_token teacher.token
        post :create, project_id: project.id
      end.to change(ProjectBundle, :count).by(1)
      expect(response).to be_success
    end

    it 'allows teacher to set team only' do
      expect(ProjectBundleJob).to_not receive(:perform_later)
      expect(ProjectTeamsBundleJob).to receive(:perform_later)
      expect do
        set_token teacher.token
        post :create, project_id: project.id, teams_only: true
      end.to change(ProjectBundle, :count).by(1)
      expect(response).to be_success
    end
    it '404 on unknown project' do
      expect do
        set_token teacher.token
        post :create, project_id: 42
      end.to change(ProjectBundle, :count).by(0)
      expect(response).to be_not_found
    end
  end

  context '.download' do
    let(:bundle){ FactoryGirl.create(:project_bundle) }
    it 'does not allow unauthorized' do
      get :download, id: bundle.id
      expect(response).to be_unauthorized
    end
    it 'does not allow student' do
      set_token student.token
      get :download, id: bundle.id
      expect(response).to be_forbidden
    end
    it 'allows teacher' do
      set_token teacher.token
      get :download, id: bundle.id
      expect(response).to be_success
    end
  end
end
