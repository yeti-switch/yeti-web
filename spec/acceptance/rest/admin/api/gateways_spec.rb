# frozen_string_literal: true

require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Gateways' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'gateways' }

  required_params = %i[name enabled priority weight acd-limit asr-limit]
  optional_params = %i[
    allow-origination allow-termination sst-enabled host port resolve-ruri diversion-rewrite-rule
    diversion-rewrite-result src-name-rewrite-rule src-name-rewrite-result src-rewrite-rule src-rewrite-result
    dst-rewrite-rule dst-rewrite-result auth-enabled auth-user auth-password auth-from-user auth-from-domain
    term-use-outbound-proxy term-force-outbound-proxy term-outbound-proxy term-next-hop-for-replies term-next-hop
    term-append-headers-req sdp-alines-filter-list ringing-timeout relay-options relay-reinvite relay-hold relay-prack
    relay-update suppress-early-media fake-180-timer transit-headers-from-origination transit-headers-from-termination
    sip-interface-name allow-1xx-without-to-tag sip-timer-b dns-srv-failover-timer anonymize-sdp proxy-media
    single-codec-in-200ok transparent-seqno transparent-ssrc force-symmetric-rtp symmetric-rtp-nonstop symmetric-rtp-ignore-rtcp
    force-dtmf-relay rtp-ping rtp-timeout filter-noaudio-streams rtp-relay-timestamp-aligning rtp-force-relay-cn
  ]

  required_relationships = %i[
    contractor codec-group sdp-c-location sensor-level
    dtmf-receive-mode dtmf-send-mode rx-inband-dtmf-filtering-mode tx-inband-dtmf-filtering-mode
    rel100-mode
    session-refresh-method
    transport-protocol sdp-alines-filter-type
    term-proxy-transport-protocol orig-proxy-transport-protocol
    network-protocol-priority media-encryption-mode sip-schema
  ]
  optional_relationships = %i[
    gateway-group pop sensor diversion-policy term-disconnect-policy
  ]

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

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

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
    let(:'sip-schema') { wrap_relationship(:'sip-schemas', 1) }
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

    jsonapi_attributes(required_params, optional_params)

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
