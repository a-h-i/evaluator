require 'rails_helper'
# Authentication testing

RSpec.describe 'Auths', type: :request do
  describe 'GET /api/users' do
    let(:user) { FactoryGirl.create(:teacher) }
    it 'requires a token' do
      get api_users_path
      expect(response).to have_http_status 401
    end
    it 'allows with token' do
      get api_users_path, nil, get_token(user.token)
      expect(response).to have_http_status 200
    end
    it 'does not authenticate tokens for deleted users' do
      token = user.token
      user.destroy
      get api_users_path, nil, get_token(token)
      expect(response).to have_http_status 401
    end
    it 'does not accept nonsense tokens' do
      token = 'sdasdsad' + user.token + 'sadsad'
      get api_users_path, nil, get_token(token)
      expect(response).to have_http_status 401
    end
    it 'does not accept expired tokens' do
      token = user.token 0
      sleep 1
      get api_users_path, nil, get_token(token)
      expect(response).to have_http_status 401
    end
  end
end
