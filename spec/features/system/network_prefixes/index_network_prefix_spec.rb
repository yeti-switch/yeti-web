# frozen_string_literal: true

RSpec.describe 'Index System Network Prefixes', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    system_network_prefixes = create_list(:network_prefix, 2)
    visit system_network_prefixes_path
    system_network_prefixes.each do |system_network_prefix|
      expect(page).to have_css('.resource_id_link', text: system_network_prefix.id)
    end
  end
end
