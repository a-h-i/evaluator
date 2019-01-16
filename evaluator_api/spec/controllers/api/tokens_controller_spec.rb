require 'rails_helper'

RSpec.describe Api::TokensController, type: :controller  do
  context '.create' do
    context 'verified users' do
      let(:user) { FactoryGirl.create(:student, verified: true) }
      it 'should have a default duration' do
        post :create, format: :json, params: {
           token: { email: user.email, password: user.password }
        }
        expect(User.find_by_token(json_response[:token])).to eql user
        expect(response).to be_created
      end
    end
    context 'unverified users' do
      let(:user) { FactoryGirl.create(:teacher, verified: false) }
      it 'should be forbidden' do
        post :create, format: :json, params: {
          token: { email: user.email, password: user.password }
        }
        expect(response).to be_forbidden
      end
    end
  end
end
