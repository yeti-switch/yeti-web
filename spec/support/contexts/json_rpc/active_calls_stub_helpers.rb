# frozen_string_literal: true

RSpec.shared_context :active_calls_stub_helpers do
  let(:stub_active_calls_collection) do
    cdrs_filter_stub = instance_double(Yeti::CdrsFilter)
    expect(Yeti::CdrsFilter).to receive(:new).with(Node.all, {}).and_return(cdrs_filter_stub)
    expect(cdrs_filter_stub).to receive(:search).with(only: nil, empty_on_error: true)
                                                .and_return(active_calls_collection.map(&:stringify_keys))
  end

  let(:stub_active_call_api_connect) do
    stub_jrpc_connect(node.rpc_endpoint)
  end

  let(:stub_active_call_single) do
    stub_active_call_api_connect
    expect_any_instance_of(NodeApi).to receive(:calls)
      .with(active_call_single[:local_tag]).once.and_return(active_call_single)
  end

  let(:stub_active_call_single_destroy) do
    stub_active_call_api_connect
    expect_any_instance_of(NodeApi).to receive(:call_disconnect)
      .with(active_call_single[:local_tag]).once
  end

  let(:active_calls_collection_qty) { 2 }
  let(:active_calls_collection) do
    FactoryBot.attributes_for_list(:active_call, active_calls_collection_qty, *active_call_attrs)
  end
  let(:active_call_single) { FactoryBot.attributes_for(:active_call, *active_call_attrs) }
  let(:active_call_attrs) { [:filled] }
end
