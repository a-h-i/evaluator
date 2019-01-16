require 'rails_helper'

RSpec.describe Api::ContactsController, type: :controller do
  context '.create' do
    let(:contact_params){FactoryGirl.attributes_for(:contact)}
    it 'allows guest' do
      expect do
        post :create, **contact_params
      end.to change(Contact, :count).by(1)
      expect(response).to be_created
    end
  end
end
