# frozen_string_literal: true

RSpec.describe 'Index DNS Zones', type: :feature do
  include_context :login_as_admin

  it 'n+1 checks' do
    zones = create_list(:dns_zone, 2)
    visit equipment_dns_zones_path
    zones.each do |d|
      expect(page).to have_css('.resource_id_link', text: d.id)
    end
  end
end
