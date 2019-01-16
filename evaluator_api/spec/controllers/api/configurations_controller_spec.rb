require 'rails_helper'

RSpec.describe Api::ConfigurationsController, type: :controller do

  it 'should list configurations' do
    get :index, format: :json
    expect(response).to be_success
  end

end
