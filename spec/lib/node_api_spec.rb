# frozen_string_literal: true

RSpec.describe NodeApi do
  let!(:nodes) { create_list(:node, 3) }
  let!(:node) { nodes[0] }

  describe '.find' do
    subject do
      NodeApi.find(node.rpc_endpoint)
    end

    before { stub_jrpc_connect(node.rpc_endpoint) }

    context 'whe pool is empty' do
      it 'responds correct NodeApi' do
        expect(subject).to be_a_kind_of(NodeApi)
        expect(subject.uri).to eq node.rpc_endpoint
      end
    end

    context 'when pool has api for such uri' do
      let!(:old_api) { NodeApi.find(node.rpc_endpoint) }

      it 'return same api' do
        expect(subject).to eq old_api
        expect(subject.object_id).to eq old_api.object_id
      end
    end

    context 'when pool has api for another uri' do
      let(:another_node) { nodes[1] }
      before { stub_jrpc_connect(another_node.rpc_endpoint) }
      let!(:another_api) { NodeApi.find(another_node.rpc_endpoint) }

      it 'returns different api' do
        expect(subject).to be_a_kind_of(NodeApi)
        expect(subject.uri).to eq node.rpc_endpoint
        expect(subject).to_not eq another_api
      end
    end
  end

  describe '.reset' do
    subject do
      NodeApi.reset(node.rpc_endpoint)
    end

    context 'when uri was not connected' do
      it { is_expected.to be_nil }

      it 'connects new api on find uri' do
        subject
        stub_jrpc_connect(node.rpc_endpoint)
        NodeApi.find(node.rpc_endpoint)
      end
    end

    context 'when uri was connected' do
      let!(:old_api) do
        stub_jrpc_connect(node.rpc_endpoint)
        NodeApi.find(node.rpc_endpoint)
      end

      it { is_expected.to be_nil }

      it 'connects new api on find uri' do
        subject
        stub_jrpc_connect(node.rpc_endpoint)
        new_api = NodeApi.find(node.rpc_endpoint)
        expect(old_api.object_id).to_not eq new_api.object_id
      end
    end

    context 'when another uri was connected' do
      let(:another_node) { nodes[1] }
      let!(:old_another_api) do
        stub_jrpc_connect(another_node.rpc_endpoint)
        NodeApi.find(another_node.rpc_endpoint)
      end

      it { is_expected.to be_nil }

      it 'connects new api on find uri' do
        subject
        stub_jrpc_connect(node.rpc_endpoint)
        NodeApi.find(node.rpc_endpoint)
      end

      it 'use cached api for another uri' do
        subject
        new_another_api = NodeApi.find(another_node.rpc_endpoint)
        expect(old_another_api.object_id).to eq new_another_api.object_id
      end
    end
  end

  describe '.new' do
    subject do
      NodeApi.new(node.rpc_endpoint)
    end

    before do
      stub_jrpc_connect(node.rpc_endpoint)
    end

    it 'creates correct instance' do
      expect(subject).to be_an_kind_of(NodeApi)
      expect(subject.uri).to eq node.rpc_endpoint
    end
  end

  describe '#sip_options_probers' do
    subject do
      described_instance.sip_options_probers(*args)
    end
    let(:described_instance) { NodeApi.new(node.rpc_endpoint) }
    let(:args) { [] }
    let(:jrpc_result) do
      [FactoryBot.attributes_for(:realtime_sip_options_prober, :filled, node_id: node.id)]
    end

    context 'no arguments' do
      before do
        stub_jrpc_request(node.rpc_endpoint, 'options_prober.show.probers', [])
          .and_return(jrpc_result.map(&:stringify_keys))
      end

      it { is_expected.to eq jrpc_result }
    end

    context 'with array of ids' do
      let(:args) { [['123']] }
      before do
        stub_jrpc_request(node.rpc_endpoint, 'options_prober.show.probers', ['123'])
          .and_return(jrpc_result.map(&:stringify_keys))
      end

      it { is_expected.to eq jrpc_result }
    end
  end

  describe '#registrations' do
    subject do
      described_instance.registrations(*args)
    end

    let(:described_instance) { NodeApi.new(node.rpc_endpoint) }
    let(:args) { [123] }
    let(:jrpc_result) { { bar: 'baz' } }

    before do
      stub_jrpc_request(node.rpc_endpoint, 'yeti.show.registrations', [123])
        .and_return(jrpc_result.stringify_keys)
    end

    it { is_expected.to eq jrpc_result }
  end

  describe '#reload_sip_options_probers' do
    subject do
      described_instance.reload_sip_options_probers
    end

    let(:described_instance) { NodeApi.new(node.rpc_endpoint) }
    let(:jrpc_result) { 'ok' }

    before do
      stub_jrpc_request(node.rpc_endpoint, 'yeti.request.options_prober.reload', [])
        .and_return(jrpc_result)
    end

    it { is_expected.to eq jrpc_result }
  end

  describe '#custom_request' do
    subject do
      described_instance.custom_request(*args)
    end

    let(:described_instance) { NodeApi.new(node.rpc_endpoint) }

    context 'with method_name' do
      let(:args) { ['some.test.method.name'] }
      let(:jrpc_result) { 'some test response' }

      before do
        stub_jrpc_request(node.rpc_endpoint, 'some.test.method.name', [])
          .and_return(jrpc_result)
      end

      it { is_expected.to eq jrpc_result }
    end

    context 'with method_name and array params' do
      let(:args) { ['some.test.method.name', [1, 2]] }
      let(:jrpc_result) { 'some test response' }

      before do
        stub_jrpc_request(node.rpc_endpoint, 'some.test.method.name', [1, 2])
          .and_return(jrpc_result)
      end

      it { is_expected.to eq jrpc_result }
    end

    context 'with method_name and hash params' do
      let(:args) { ['some.test.method.name', { foo: 'bar' }] }
      let(:jrpc_result) { 'some test response' }

      before do
        stub_jrpc_request(node.rpc_endpoint, 'some.test.method.name', { foo: 'bar' })
          .and_return(jrpc_result)
      end

      it { is_expected.to eq jrpc_result }
    end
  end
end
