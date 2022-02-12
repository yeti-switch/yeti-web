# frozen_string_literal: true

RSpec.describe 'Create new Api Access', type: :feature, js: true do
  include_context :login_as_admin

  before do
    @customer = create(:customer)
    @account = create(:account, contractor: @customer)

    visit new_api_access_path
  end

  context 'with pre-filled form' do
    include_context :fill_form, 'new_system_api_access' do
      let(:attributes) do
        {
          login: 'Account',
          password: 'Pass',
          customer_id: lambda {
                         fill_in_chosen('Customer', with: @customer.name, ajax: true)
                       },
          formtastic_allowed_ips: '127.0.0.1,1.1.0.0/16'
        }
      end

      it 'creates new api access succesfully' do
        click_on_submit

        expect(page).to have_css('.flash_notice', text: 'Api access was successfully created.')

        expect(System::ApiAccess.last).to have_attributes(
          login: attributes[:login],
          customer_id: @account.contractor.id,
          allowed_ips: attributes[:formtastic_allowed_ips].split(',')
        )
      end
    end
  end

  context 'validate credentials generator' do
    active_admin_form_for System::ApiAccess, 'new'

    context 'when credentials is empty' do
      it 'should generate new credential by click on the link in hint for :login with 20 chars' do
        click_link('Сlick to fill random login')
        login = find_field('system_api_access_login')
        expect(login).to be_present
        expect(login.value).to be_present
        expect(login.value).to match(/\A[a-zA-Z0-9]+\z/)
        expect(login.value.length).to eq(20)
      end

      it 'should generate new credential by click on the link in hint for :password with 20 chars' do
        click_link('Сlick to fill random password')
        password = find_field('system_api_access_password')
        expect(password).to be_present
        expect(password.value).to be_present
        expect(password.value).to match(/\A[a-zA-Z0-9]+\z/)
        expect(password.value.length).to eq(20)
      end

      it 'should not autogenerate new credential for :login' do
        login = find_field('system_api_access_login')
        expect(login).to be_present
        expect(login.value).to be_empty
      end

      it 'should not autogenerate new credential for :password' do
        password = find_field('system_api_access_password')
        expect(password).to be_present
        expect(password.value).to be_empty
      end
    end

    context 'when credentials are present' do
      before do
        aa_form.set_text 'system_api_access_login', 'TestCredential'
        aa_form.set_text 'system_api_access_password', 'TestCredential'
      end

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

      it 'should not autogenerate new credential for :login' do
        login = find_field('system_api_access_login')
        expect(login).to be_present
        expect(login.value).to be_present
        expect(login.value).to eq('TestCredential')
      end

      it 'should not autogenerate new credential for :password' do
        password = find_field('system_api_access_password')
        expect(password).to be_present
        expect(password.value).to be_present
        expect(password.value).to eq('TestCredential')
      end
    end
  end
end
