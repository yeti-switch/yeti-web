# frozen_string_literal: true

RSpec.describe 'Index System Disconnect Codes', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    disconnect_codes = create_list(:disconnect_code, 2, :sip)
    visit disconnect_codes_path
    disconnect_codes.each do |disconnect_code|
      expect(page).to have_css('.resource_id_link', text: disconnect_code.id)
    end
  end
end
