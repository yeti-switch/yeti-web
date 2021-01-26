RSpec.describe NodeRpcClient do
  let!(:node) { create(:node) }

  before do
    stub_jrpc_request('options_prober.show.probers', node.rpc_endpoint, { logger: be_present }).and_return([{ id: 1 }])
  end

  it 'returns' do
    result = NodeRpcClient.new(node.rpc_endpoint).sip_options_probers
    expect(result).to eq([{ id: 1 }])
  end
end
