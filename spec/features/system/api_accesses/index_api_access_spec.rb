# frozen_string_literal: true

RSpec.describe 'Index Api Accesses', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    api_accesss = create_list(:api_access, 2)
    visit customer_portal_logins_path
    api_accesss.each do |api_access|
      expect(page).to have_css('.resource_id_link', text: api_access.id)
    end
  end
end
