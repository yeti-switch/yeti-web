# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'ActiveCalls' do
  include_context :acceptance_admin_user
  let(:type) { 'active-calls' }

  include_context :active_calls_stub_helpers do
    let!(:node) { FactoryBot.create(:node) }
    let(:active_call_attrs) { [:filled, node_id: node.id] }
  end

  get '/api/rest/admin/active-calls' do
    jsonapi_filters Api::Rest::Admin::ActiveCallResource._allowed_filters

    before { stub_active_calls_collection }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/active-calls/:id' do
    let(:id) { "#{active_call_single[:node_id]}*#{active_call_single[:local_tag]}" }

    before { stub_active_call_single }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/active-calls/:id' do
    let(:id) { "#{active_call_single[:node_id]}*#{active_call_single[:local_tag]}" }

    before do
      stub_active_call_single
      stub_active_call_single_destroy
    end

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
