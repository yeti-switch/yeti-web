# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Gateways' do
  include_context :acceptance_admin_user
  let(:type) { 'gateways' }

  resource_data = jsonapi_extract_fields_data(Api::Rest::Admin::GatewayResource)

  required_attributes = %i[name enabled priority weight acd-limit asr-limit]
  optional_attributes = resource_data[:creatable_attributes] - required_attributes

  required_relationships = %i[
    contractor codec-group sdp-c-location sensor-level
    dtmf-receive-mode dtmf-send-mode rx-inband-dtmf-filtering-mode tx-inband-dtmf-filtering-mode
    rel100-mode
    session-refresh-method
    transport-protocol sdp-alines-filter-type
    term-proxy-transport-protocol orig-proxy-transport-protocol
    network-protocol-priority media-encryption-mode
  ]
  optional_relationships = resource_data[:creatable_relationships] - required_relationships

  get '/api/rest/admin/gateways' do
    jsonapi_filters Api::Rest::Admin::GatewayResource._allowed_filters

    before { create_list(:gateway, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/gateways/:id' do
    let(:id) { create(:gateway).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/gateways' do
    parameter :type, 'Resource type (gateways)', scope: :data, required: true

    jsonapi_attributes(required_attributes, optional_attributes)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:'external-id') { 100_500 }
    let(:name) { 'name' }
    let(:enabled) { true }
    let(:allow_origination) { true }
    let(:allow_termination) { true }
    let(:host) { 'test.example.com' }
    let(:priority) { 1 }
    let(:weight) { 900 }
    let(:'acd-limit') { 0.0 }
    let(:'asr-limit') { 0.0 }
    let(:'sdp-alines-filter-type') { wrap_relationship(:'filter-types', 0) }
    let(:'session-refresh-method') { wrap_relationship(:'session-refresh-methods', 1) }
    let(:'sdp-c-location') { wrap_relationship(:'sdp-c-locations', 2) }
    let(:'sensor-level') { wrap_relationship(:'sensor-levels', 1) }
    let(:'dtmf-receive-mode') { wrap_relationship(:'dtmf-receive-modes', 1) }
    let(:'dtmf-send-mode') { wrap_relationship(:'dtmf-send-modes', 1) }
    let(:'rel100-mode') { wrap_relationship(:'gateway-rel100-modes', 1) }
    let(:'tx-inband-dtmf-filtering-mode') { wrap_relationship(:'gateway-inband-dtmf-filtering-modes', 2) }
    let(:'rx-inband-dtmf-filtering-mode') { wrap_relationship(:'gateway-inband-dtmf-filtering-modes', 3) }
    let(:'transport-protocol') { wrap_relationship(:'transport-protocols', 1) }
    let(:'term-proxy-transport-protocol') { wrap_relationship(:'transport-protocols', 1) }
    let(:'orig-proxy-transport-protocol') { wrap_relationship(:'transport-protocols', 1) }
    let(:'media-encryption-mode') { wrap_relationship(:'gateway-media-encryption-modes', 2) }
    let(:'network-protocol-priority') { wrap_relationship(:'gateway-network-protocol-priorities', 3) }
    let(:contractor) { wrap_relationship(:contractors, create(:contractor, vendor: true).id) }
    let(:'codec-group') { wrap_relationship(:'codec-groups', create(:codec_group).id) }

    example_request 'create new entry' do
      #      p response_body
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/gateways/:id' do
    parameter :type, 'Resource type (gateways)', scope: :data, required: true
    parameter :id, 'Gateway ID', scope: :data, required: true

    jsonapi_attributes(required_attributes, optional_attributes)

    let(:id) { create(:gateway).id }
    let(:name) { 'name' }
    let(:'acd-limit') { 1.0 }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/gateways/:id' do
    let(:id) { create(:gateway).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
