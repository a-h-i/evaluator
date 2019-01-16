require 'rails_helper'

RSpec.describe TeamAssignmentJob, type: :job do
  let(:model) { FactoryGirl.create(:team_job) }

  it 'sends status notifications' do
    expect(model).to receive(:send_status).exactly(4).times
    TeamAssignmentJob.perform_now(model)
  end
end
