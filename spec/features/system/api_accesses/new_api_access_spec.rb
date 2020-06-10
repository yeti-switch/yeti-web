# frozen_string_literal: true

RSpec.describe 'Create new Api Access', type: :feature, js: true do
  include_context :login_as_admin

  before do
    @account = create(:account)

    visit new_api_access_path
  end

  include_context :fill_form, 'new_system_api_access' do
    let(:attributes) do
      {
        login: 'Account',
        password: 'Pass',
        customer_id: lambda {
                       chosen_pick('#system_api_access_customer_id+div', text: @account.contractor.name)
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
