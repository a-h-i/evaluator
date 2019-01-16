require 'rails_helper'

RSpec.describe Api::TeamsController, type: :controller do
  let(:student_one) do
    FactoryGirl.create(:student, guc_suffix: 4477, guc_prefix: 16, team: 'old')
  end
  let(:student_two) do
    FactoryGirl.create(:student, guc_suffix: 8888, guc_prefix: 32, team: 'old')
  end
  let(:student_three) do
    FactoryGirl.create(:student, guc_suffix: 1337, guc_prefix: 28, team: 'old')
  end
  let(:student) { FactoryGirl.create(:student) }
  let(:teacher) { FactoryGirl.create(:teacher) }
  let(:admin) { FactoryGirl.create(:super_user) }
  before :each do
    @file = fixture_file_upload('/files/teams/teams_example.csv', "text/csv", true)
  end

  context '.create' do
    it 'does not allow unauthorized' do
      student_one
      student_two
      student_three
      expect(TeamAssignmentJob).to_not receive(:perform_later)
      expect { post :create, file: @file }.to change(TeamJob, :count).by(0)
      expect(response).to be_unauthorized
    end
    it 'does not allow student' do
      student_one
      student_two
      student_three
      set_token student.token
      expect(TeamAssignmentJob).to_not receive(:perform_later)
      expect { post :create, file: @file }.to change(TeamJob, :count).by(0)
      expect(response).to be_forbidden
      student_one.reload
      student_two.reload
      student_three.reload
      expect(student_one.team).to eql 'old'
      expect(student_two.team).to eql 'old'
      expect(student_three.team).to eql 'old'
    end
    it 'does not allow teacher' do
      student_one
      student_two
      student_three
      set_token teacher.token
      expect(TeamAssignmentJob).to_not receive(:perform_later)
      expect { post :create, file: @file }.to change(TeamJob, :count).by(0)
      expect(response).to be_forbidden
      student_one.reload
      student_two.reload
      student_three.reload
      expect(student_one.team).to eql 'old'
      expect(student_two.team).to eql 'old'
      expect(student_three.team).to eql 'old'
    end
    it 'allows an admin' do
      student_one
      student_two
      student_three
      set_token admin.token
      expect(TeamAssignmentJob).to receive(:perform_later)
      expect { post :create, file: @file }.to change(TeamJob, :count).by(1)
      expect(response).to be_success
    end
    it 'sets teams' do
      student_one
      student_two
      student_three
      set_token admin.token
      expect { post :create, file: @file }.to change(TeamJob, :count).by(1)
      expect(response).to be_success
      student_one.reload
      student_two.reload
      student_three.reload
      expect(student_one.team).to eql 'betengan'
      expect(student_two.team).to eql 'angry beavers'
      expect(student_three.team).to eql 'bag of emotions'
    end
  end
  context '.index' do
    it 'does not allow unauthorized' do
      get :index
      expect(response).to be_unauthorized
    end
    it 'does not allow student' do
      set_token student.token
      get :index
      expect(response).to be_forbidden
    end
    it 'allows teacher' do
      set_token teacher.token
      get :index
      expect(response).to be_success
    end
  end
end
