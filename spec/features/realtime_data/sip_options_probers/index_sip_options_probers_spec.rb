# frozen_string_literal: true

RSpec.describe 'Sip Options Probers index page', js: true do
  include_context :login_as_admin

  subject do
    visit sip_options_probers_path
    stub_jrpc_request('options_prober.show.probers', nodes.first.rpc_endpoint, { logger: be_present }).and_return([{ id: nodes.first.id }])
    stub_jrpc_request('options_prober.show.probers', nodes.second.rpc_endpoint, { logger: be_present }).and_return([{ id: nodes.second.id }])
  end

  let!(:nodes) { create_list(:node, 2) }
  let(:jrpc_response) do
    NodeRpcClient.perform_parallel(default: []) do |client, node|
      result = client.sip_options_probers
      result.map { |row| row.merge(node: node) }
    end
  end

  it 'returns correct Sip Options Probers' do
    subject

    expect(page).to have_table
    expect(page).to have_table_row count: jrpc_response.size
    jrpc_response.each { |sip_options_prober| expect(page).to have_table_cell column: 'Id', text: sip_options_prober[:id] }
  end
end
