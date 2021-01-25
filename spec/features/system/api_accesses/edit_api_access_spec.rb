# frozen_string_literal: true

RSpec.describe 'Update Api Access', type: :feature, js: true do
  include_context :login_as_admin

  before do
    @account = FactoryBot.create(:account)
    visit edit_api_access_path(api_access.id)
  end

  context 'validate credentials generator' do
    let!(:attributes) do
      {
        login: 'Account',
        password: 'Pass',
        customer_id: @account.contractor_id,
        formtastic_allowed_ips: '127.0.0.1,1.1.0.0/16'
      }
    end

    let!(:api_access) { FactoryBot.create(:api_access, attributes) }

    it 'should generate new credential by click on the link in hint for :login with 20 chars' do
      click_link('Сlick to fill random login')
      login = find_field('system_api_access_login')
      expect(login).to be_present
      expect(login.value).to be_present
      expect(login.value).to match(/\A[a-zA-Z0-9]+\z/)
      expect(login.value.length).to eq(20)
      expect(login.value).not_to eq('TestCredential')
    end

    it 'should generate new credential by click on the link in hint for :password with 20 chars' do
      click_link('Сlick to fill random password')
      password = find_field('system_api_access_password')
      expect(password).to be_present
      expect(password.value).to be_present
      expect(password.value).to match(/\A[a-zA-Z0-9]+\z/)
      expect(password.value.length).to eq(20)
      expect(password.value).not_to eq('TestCredential')
    end

    it 'should not autogenerate credential for :password even if value empty' do
      # Password implemented via has_secure_password,
      # in edit forms it's value always should be empty or manually entering to applying changes
      password = find_field('system_api_access_password')
      expect(password).to be_present
      expect(password.value).to be_empty
    end
  end
end
