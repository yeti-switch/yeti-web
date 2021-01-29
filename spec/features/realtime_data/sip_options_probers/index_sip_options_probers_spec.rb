# frozen_string_literal: true

RSpec.describe 'Sip Options Probers index page', js: true do
  include_context :login_as_admin

  subject do
    visit sip_options_probers_path
  end

  before do
    stub_jrpc_request('options_prober.show.probers', nodes.first.rpc_endpoint, { logger: be_present })
      .and_return([record_attributes.first.stringify_keys])
    stub_jrpc_request('options_prober.show.probers', nodes.second.rpc_endpoint, { logger: be_present })
      .and_return([record_attributes.second.stringify_keys])
  end

  let!(:nodes) { create_list(:node, 2) }
  let(:record_attributes) do
    [
      FactoryBot.attributes_for(:sip_options_prober, :filled, node_id: nodes.first.id),
      FactoryBot.attributes_for(:sip_options_prober, :filled, node_id: nodes.second.id)
    ]
  end

  it 'returns correct Sip Options Probers' do
    subject

    expect(page).to have_table
    expect(page).to have_table_row count: nodes.size
    nodes.each { |node| expect(page).to have_link(node.name, href: node_path(node.id)) }
    record_attributes.each do |record_attribute|
      expect(page).to have_link(record_attribute[:name], href: equipment_sip_options_prober_path(record_attribute[:id]))
    end
    record_attributes.each { |record_attribute| expect(page).to have_table_cell column: 'Id', text: record_attribute[:id] }
  end

  it 'returns correct Sip Options Prober{#id}' do
    subject

    record_attributes.each do |record_attribute|
      expect(page).to have_link(record_attribute[:id].to_s, href: sip_options_prober_path("#{record_attribute[:node_id]}*#{record_attribute[:id]}"))
    end
    click_link({ href: sip_options_prober_path("#{record_attributes.first[:node_id]}*#{record_attributes.first[:id]}")})
    click_link(record_attributes.first[:id])
    record_attributes.first.each { |attribute| expect(page).to have_table_cell text: attribute }
  end
end
