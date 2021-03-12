# frozen_string_literal: true

RSpec.describe 'Index Gateways', type: :feature do
  subject do
    visit gateways_path
  end

  include_context :login_as_admin

  let!(:vendor) { create(:vendor) }
  let!(:gateway_group) { create(:gateway_group, vendor: vendor) }
  let!(:gateways) do
    create_list(
      :gateway, 2,
      :filled,
      contractor: vendor,
      gateway_group: gateway_group
    )
  end

  it 'n+1 checks' do
    subject
    gateways.each do |gateway|
      expect(page).to have_css('.resource_id_link', text: gateway.id)
    end
  end
end
