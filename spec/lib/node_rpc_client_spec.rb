# frozen_string_literal: true

RSpec.describe NodeRpcClient do
  let!(:node) { create(:node) }

  before do
    stub_jrpc_request('options_prober.show.probers', node.rpc_endpoint, { logger: be_present }).and_return([{ id: 1 }])
  end

  let(:jrpc_response) { NodeRpcClient.new(node.rpc_endpoint).sip_options_probers }

  it 'returns correct sip option prober' do
    expect(jrpc_response).to eq([{ id: 1 }])
  end
end
