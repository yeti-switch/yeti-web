require 'spec_helper'

describe Api::Rest::Admin::AuthController, type: :controller do
  let!(:admin) { create :admin_user, username: 'admin', password: 'password' }

  before { request.accept = 'application/json' }

  describe 'POST create' do

    before { post :create, params: { auth: attributes } }

    context 'when attributes are valid' do
      let(:attributes) { { username: 'admin', password: 'password' } }

      context 'ldap' do
        before do
          allow(AdminUser).to receive(:ldap_config_exists?){ true }
        end

        it { expect(response.status).to eq(201) }
        it { expect(JSON.parse(response.body).has_key?('jwt')).to be_truthy }
      end

      context 'no ldap' do
        before do
          allow(AdminUser).to receive(:ldap_config_exists?){ false }
        end

        it { expect(response.status).to eq(201) }
        it { expect(JSON.parse(response.body).has_key?('jwt')).to be_truthy }
      end

    end

    context 'when attributes are invalid' do
      let(:attributes) { { username: 'admin', password: 'wrong_password' } }

      it { expect(response.status).to eq(404) }
      it { expect(response.body.blank?).to be_truthy }
    end
  end
end

