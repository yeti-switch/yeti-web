# frozen_string_literal: true

RSpec.describe NodeRpcClient, '#sip_options_probers' do
  subject do
    NodeRpcClient.new(node.rpc_endpoint).sip_options_probers
  end

  before do
    stub_jrpc_request('options_prober.show.probers', node.rpc_endpoint, { logger: be_present }).and_return([{ id: 1 }])
  end

  let!(:node) { create(:node) }

  it 'returns correct sip option prober' do
    expect(subject).to eq([{ id: 1 }])
  end
end
