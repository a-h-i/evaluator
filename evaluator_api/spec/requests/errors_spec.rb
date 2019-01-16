require 'rails_helper'

RSpec.describe 'Errors', type: :request do
  describe 'GET /errors' do
    it 'rescues errors' do
      user = FactoryGirl.create(:teacher)
      expect(User).to receive(:find_by_token).and_raise('Some fancy error')
      get api_users_path, nil, get_token(user.token)
      expect(response).to have_http_status 500
      expect(json_response).to include(:message)
    end
  end
end
