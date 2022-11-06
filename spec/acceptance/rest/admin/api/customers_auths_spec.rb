# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Customer Auths' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'customers-auths' }

  required_params = %i[name ip]
  optional_params = %i[
    enabled reject-calls src-rewrite-rule src-rewrite-result dst-rewrite-rule dst-rewrite-result src-prefix dst-prefix x-yeti-auth
    capacity uri-domain src-name-rewrite-rule src-name-rewrite-result diversion-rewrite-rule
    diversion-rewrite-result allow-receive-rate-limit send-billing-information
    enable-audio-recording src-number-radius-rewrite-rule src-number-radius-rewrite-result
    dst-number-radius-rewrite-rule dst-number-radius-rewrite-result from-domain to-domain
    tag-action-value check-account-balance require-incoming-auth dump-level-id
  ]

  required_relationships = %i[customer rateplan routing-plan gateway account diversion-policy]
  optional_relationships = %i[
    pop dst-numberlist src-numberlist radius-auth-profile radius-accounting-profile transport-protocol
    tag-action
  ]

  get '/api/rest/admin/customers-auths' do
    jsonapi_filters Api::Rest::Admin::CustomersAuthResource._allowed_filters

    before { create_list(:customers_auth, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/customers-auths/:id' do
    let(:id) { create(:customers_auth).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/customers-auths' do
    parameter :type, 'Resource type (customers-auths)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:name) { 'name' }
    let(:enabled) { true }
    let(:'reject-calls') { false }
    let(:ip) { '0.0.0.0' }
    let(:'dump-level-id') { CustomersAuth::DUMP_LEVEL_CAPTURE_ALL }
    let(:'diversion-policy') { wrap_relationship(:'diversion-policies', 1) }
    let(:customer) { wrap_relationship(:contractors, create(:contractor, customer: true).id) }
    let(:rateplan) { wrap_relationship(:rateplans, create(:rateplan).id) }
    let(:'routing-plan') { wrap_relationship(:'routing-plans', create(:routing_plan).id) }
    let(:gateway) { wrap_relationship(:gateways, create(:gateway).id) }
    let(:account) { wrap_relationship(:accounts, create(:account).id) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/customers-auths/:id' do
    parameter :type, 'Resource type (customers-auths)', scope: :data, required: true
    parameter :id, 'Customer Auth ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)

    let(:id) { create(:customers_auth).id }
    let(:name) { 'name' }
    let(:capacity) { 2 }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/customers-auths/:id' do
    let(:id) { create(:customers_auth).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
