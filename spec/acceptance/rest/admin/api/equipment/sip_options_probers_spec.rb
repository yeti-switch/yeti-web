# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Sip options prober' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'sip-options-probers' }

  required_params = %i[name ruri-username ruri-domain]
  optional_params = %i[
    append-headers
    auth-password
    auth-username
    contact-uri
    enabled
    from-uri
    interval
    proxy
    sip-interface-name
    sip-schema-id
    to-uri
    created-at
    updated-at
    external-id
  ]

  required_relationships = %i[transport-protocol proxy-transport-protocol]
  optional_relationships = %i[node pop]

  get '/api/rest/admin/equipment/sip-options-probers' do
    jsonapi_filters Api::Rest::Admin::Equipment::SipOptionsProberResource._allowed_filters

    let!(:sip_options_probers) { create_list(:sip_options_prober, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/equipment/sip-options-probers/:id' do
    let(:id) { create(:sip_options_prober).id }

    example_request 'get specific entry', timezone: Time.zone do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/equipment/sip-options-probers' do
    parameter :type, 'Resource type (sip-options-probers)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:name) { 'name' }
    let(:'ruri-username') { 'ruri-username' }
    let(:'ruri-domain') { 'ruri-domain' }

    let(:'transport-protocol') { wrap_relationship(:'transport-protocols', 1) }
    let(:'proxy-transport-protocol') { wrap_relationship(:'transport-protocols', 1) }
    let(:'sip-schema') { 1 }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/equipment/sip-options-probers/:id' do
    parameter :type, 'Resource type (sip-options-probers)', scope: :data, required: true
    parameter :id, 'Sip Options Prober ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:id) { create(:sip_options_prober).id }
    let(:name) { 'test_name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/equipment/sip-options-probers/:id' do
    let(:id) { create(:sip_options_prober).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
