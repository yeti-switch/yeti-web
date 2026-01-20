# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'SIP Registration' do
  include_context :acceptance_admin_user
  let(:type) { 'registrations' }

  required_params = %i[domain name contact username sip-schema-id]
  optional_params = %i[
    auth-password
    auth-user
    contact
    display_username
    domain
    enabled
    expire
    force-expire
    max-attempts
    route-set
    retry-delay
    sip-interface-name
  ]

  required_relationships = %i[transport-protocol]
  optional_relationships = %i[node pop]

  get '/api/rest/admin/registrations' do
    jsonapi_filters Api::Rest::Admin::RegistrationResource._allowed_filters

    let!(:registrations) { create_list(:registration, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/registrations/:id' do
    let(:id) { create(:registration).id }

    example_request 'get specific entry', timezone: Time.zone do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/registrations' do
    parameter :type, 'Resource type (registrations)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:name) { 'name' }
    let(:username) { 'ruri-username' }
    let(:domain) { 'ruri-domain' }
    let(:'sip-schema-id') { 1 }
    let(:contact) { 'sip:contact@domain;param' }

    let(:'transport-protocol') { wrap_relationship(:'transport-protocols', 1) }
    let(:'sip-schema-id') { 1 }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/registrations/:id' do
    parameter :type, 'Resource type (registrations)', scope: :data, required: true
    parameter :id, 'Registration ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:id) { create(:registration).id }
    let(:name) { 'test_name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/registrations/:id' do
    let(:id) { create(:registration).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
