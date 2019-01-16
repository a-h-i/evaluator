require 'rails_helper'

RSpec.describe RerunSubmissionsJob, type: :job do
  let(:project) do
    FactoryGirl.create(:project, published: true,
      course: FactoryGirl.create(:course, published: true))
  end
  let(:submissions) do
    5.times { FactoryGirl.create(:submission_with_code, project: project) }
  end

  it 'Enques evaluation wrappers' do
    expect(RerunEvaluationWrapperJob).to receive(:perform_later).exactly(5).times
    submissions
    RerunSubmissionsJob.perform_now(project)
  end

end
