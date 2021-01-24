# frozen_string_literal: true

RSpec.describe 'Update Gateway', type: :feature, js: true do
  include_context :login_as_admin

  before do
    visit edit_gateway_path(gateway.id)
  end

  context 'validate credentials generator' do
    before do
      click_on 'Signaling'
    end

    context 'when credentials is empty' do
      let!(:gateway) { FactoryBot.create(:gateway, incoming_auth_username: nil, incoming_auth_password: nil) }

      it 'should generate new credential by click on the link in hint for :incoming_auth_username with 20 chars' do
        click_link('Сlick to fill random username')
        incoming_auth_username = find_field('gateway_incoming_auth_username')
        expect(incoming_auth_username).to be_present
        expect(incoming_auth_username.value).to be_present
        expect(incoming_auth_username.value).to match(/\A[a-zA-Z0-9]+\z/)
        expect(incoming_auth_username.value.length).to eq(20)
      end

      it 'should generate new credential by click on the link in hint for :incoming_auth_password with 20 chars' do
        click_link('Сlick to fill random password')
        incoming_auth_password = find_field('gateway_incoming_auth_password')
        expect(incoming_auth_password).to be_present
        expect(incoming_auth_password.value).to be_present
        expect(incoming_auth_password.value).to match(/\A[a-zA-Z0-9]+\z/)
        expect(incoming_auth_password.value.length).to eq(20)
      end

      it 'should not autogenerate credential for :incoming_auth_username' do
        incoming_auth_username = find_field('gateway_incoming_auth_username')
        expect(incoming_auth_username).to be_present
        expect(incoming_auth_username.value).to be_empty
      end

      it 'should not autogenerate credential for :incoming_auth_password' do
        incoming_auth_password = find_field('gateway_incoming_auth_password')
        expect(incoming_auth_password).to be_present
        expect(incoming_auth_password.value).to be_empty
      end
    end

    context 'when credentials are present' do
      let!(:gateway) { FactoryBot.create(:gateway, incoming_auth_username: 'TestCredential', incoming_auth_password: 'TestCredential') }

      it 'should generate new credential by click on the link in hint for :incoming_auth_username with 20 chars' do
        click_link('Сlick to fill random username')
        incoming_auth_username = find_field('gateway_incoming_auth_username')
        expect(incoming_auth_username).to be_present
        expect(incoming_auth_username.value).to be_present
        expect(incoming_auth_username.value).to match(/\A[a-zA-Z0-9]+\z/)
        expect(incoming_auth_username.value.length).to eq(20)
        expect(incoming_auth_username.value).not_to eq('TestCredential')
      end

      it 'should generate new credential by click on the link in hint for :incoming_auth_password with 20 chars' do
        click_link('Сlick to fill random password')
        incoming_auth_password = find_field('gateway_incoming_auth_password')
        expect(incoming_auth_password).to be_present
        expect(incoming_auth_password.value).to be_present
        expect(incoming_auth_password.value).to match(/\A[a-zA-Z0-9]+\z/)
        expect(incoming_auth_password.value.length).to eq(20)
        expect(incoming_auth_password.value).not_to eq('TestCredential')
      end

      it 'should not autogenerate new credential for :incoming_auth_username' do
        incoming_auth_username = find_field('gateway_incoming_auth_username')
        expect(incoming_auth_username).to be_present
        expect(incoming_auth_username.value).to be_present
        expect(incoming_auth_username.value).to eq('TestCredential')
      end

      it 'should not autogenerate new credential for :incoming_auth_password' do
        incoming_auth_password = find_field('gateway_incoming_auth_password')
        expect(incoming_auth_password).to be_present
        expect(incoming_auth_password.value).to be_present
        expect(incoming_auth_password.value).to eq('TestCredential')
      end
    end
  end
end
