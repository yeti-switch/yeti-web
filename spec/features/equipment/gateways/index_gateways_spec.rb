# frozen_string_literal: true

RSpec.describe 'Index Gateways', type: :feature do
  include_context :login_as_admin

  let(:vendor) { create(:vendor) }
  let(:gateway_group) { create(:gateway_group, vendor: vendor) }
  it 'n+1 checks' do
    gateways = create_list(
      :gateway, 2, :filled,
      contractor: vendor,
      gateway_group: gateway_group
    )
    visit gateways_path
    gateways.each do |gateway|
      expect(page).to have_css('.resource_id_link', text: gateway.id)
    end
  end
end
