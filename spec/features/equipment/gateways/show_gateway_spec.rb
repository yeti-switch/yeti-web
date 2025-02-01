# frozen_string_literal: true

RSpec.describe 'Show Gateway', type: :feature do
  subject do
    visit gateway_path(gateway.id)
  end

  include_context :login_as_admin

  let!(:node) { create(:node) }
  let!(:vendor) { create(:vendor) }
  let!(:gateway_group) { create(:gateway_group, vendor: vendor) }
  let!(:gateway) do
    create(
      :gateway,
      :filled,
      contractor: vendor,
      gateway_group: gateway_group
    )
  end

  context 'when node turned off' do
    before { stub_jrpc_connect_error(node.rpc_endpoint) }

    it 'shows gateway details page' do
      subject
      expect(page).to have_attribute_row('ID', exact_text: gateway.id)
      expect(page).to_not have_flash_message(type: :warning, count: 1)
      expect(page).to have_flash_message(
                        "#{node.rpc_endpoint} - can't connect to #{node.rpc_endpoint}",
                        type: :warning
                      )
    end
  end

  context 'when node is active' do
    before do
      registration_data = FactoryBot.attributes_for(:incoming_registration, :filled).stringify_keys
      stub_jrpc_request(node.rpc_endpoint, 'registrar.show.aors', [gateway.id]).and_return([registration_data])
    end

    it 'shows gateway details page' do
      subject
      expect(page).to have_attribute_row('ID', exact_text: gateway.id)
      expect(page).to_not have_flash_message(nil, type: :warning)
    end
  end
end
