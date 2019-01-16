require 'rails_helper'

RSpec.describe DestroyProjectBundleJob, type: :job do
  let(:bundle) {FactoryGirl.create(:project_bundle)}
  
  it 'destroys bundle' do
    bundle
    expect do
      DestroyProjectBundleJob.perform_now(bundle)
    end.to change(ProjectBundle, :count).by(-1)
  end

end
