# frozen_string_literal: true

RSpec.describe 'Sip Options Probers index page', js: true do
  include_context :login_as_admin

  subject do
    visit sip_options_probers_path
  end

  before do
    stub_jrpc_request('options_prober.show.probers', nodes.first.rpc_endpoint, { logger: be_present }).and_return([{ id: nodes.first.id }])
    stub_jrpc_request('options_prober.show.probers', nodes.second.rpc_endpoint, { logger: be_present }).and_return([{ id: nodes.second.id }])
  end

  let!(:nodes) { create_list(:node, 2) }

  it 'returns correct Sip Options Probers' do
    subject

    expect(page).to have_table
    expect(page).to have_table_row count: nodes.size
    nodes.each { |node| expect(page).to have_table_cell column: 'Id', text: node[:id] }
  end
end
