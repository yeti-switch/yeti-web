# frozen_string_literal: true

RSpec.describe NodeRpcClient, '#sip_options_probers' do
  subject do
    NodeRpcClient.new(node.rpc_endpoint).sip_options_probers
  end

  before do
    stub_jrpc_request('options_prober.show.probers', node.rpc_endpoint, { logger: be_present })
      .and_return([response_attribute])
  end

  let!(:node) { create(:node) }
  let(:response_attribute) { FactoryBot.attributes_for(:sip_options_prober, :filled, node_id: node.id) }

  context 'with ids' do
    it 'returns correct sip option prober' do
      expect(subject).to eq([response_attribute])
    end
  end
end
