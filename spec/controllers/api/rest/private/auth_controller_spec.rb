require 'spec_helper'

describe Api::Rest::Private::AuthController, type: :controller do
  let!(:admin) { create :admin_user, username: 'admin', email: 'admin@example.com', password: 'password' }

  before { request.accept = 'application/json' }

  describe 'POST create' do
    before { post :create, auth: attributes }

    context 'when attributes are valid' do
      let(:attributes) { { username: 'admin', password: 'password' } }

      it { expect(response.status).to eq(201) }
      it { expect(JSON.parse(response.body).has_key?('jwt')).to be_truthy }
    end

    context 'when attributes are invalid' do
      let(:attributes) { { username: 'admin', password: 'wrong_password' } }

      it { expect(response.status).to eq(404) }
      it { expect(response.body.blank?).to be_truthy }
    end
  end
end

