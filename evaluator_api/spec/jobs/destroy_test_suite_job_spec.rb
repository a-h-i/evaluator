require 'rails_helper'

RSpec.describe DestroyTestSuiteJob, type: :job do
  let(:suite){FactoryGirl.create(:test_suite)}
  let(:results){FactoryGirl.create_list(:result, 5, test_suite: suite)}

  it 'only deletes results' do
    results
    expect do
      DestroyTestSuiteJob.perform_now(suite)
    end.to change(Submission, :count).by(0).and(
      change(Result, :count).by(-5)).and(
      change(TestSuite, :count).by(-1))
  end
end
