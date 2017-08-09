require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Customer Auths' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'customers-auths' }

  required_params = %i(
    name ip customer-id rateplan-id routing-plan-id gateway-id account-id
    dump-level-id diversion-policy-id
  )

  optional_params = %i(
    enabled src-rewrite-rule src-rewrite-result dst-rewrite-rule dst-rewrite-result src-prefix dst-prefix x-yeti-auth
    capacity pop-id uri-domain src-name-rewrite-rule src-name-rewrite-result diversion-rewrite-rule
    diversion-rewrite-result dst-numberlist-id src-numberlist-id allow-receive-rate-limit send-billing-information
    radius-auth-profile-id enable-audio-recording src-number-radius-rewrite-rule src-number-radius-rewrite-result
    dst-number-radius-rewrite-rule dst-number-radius-rewrite-result radius-accounting-profile-id from-domain to-domain
    transport-protocol-id
  )

  get '/api/rest/private/customers-auths' do
    before { create_list(:customers_auth, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/customers-auths/:id' do
    let(:id) { create(:customers_auth).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/customers-auths' do
    parameter :type, 'Resource type (customers-auths)', scope: :data, required: true

    required_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('-', ' '), scope: [:data, :attributes], required: true
    end

    optional_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('-', ' '), scope: [:data, :attributes]
    end

    let(:name) { 'name' }
    let(:enabled) { true }
    let(:ip) { '0.0.0.0' }
    let(:'dump-level-id') { 1 }
    let(:'diversion-policy-id') { 1 }
    let(:'customer-id') { create(:contractor, customer: true).id }
    let(:'rateplan-id') { create(:rateplan).id }
    let(:'routing-plan-id') { create(:routing_plan).id }
    let(:'gateway-id') { create(:gateway).id }
    let(:'account-id') { create(:account).id }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/customers-auths/:id' do
    parameter :type, 'Resource type (customers-auths)', scope: :data, required: true
    parameter :id, 'Customer Auth ID', scope: :data, required: true

    required_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('-', ' '), scope: [:data, :attributes], required: true
    end

    optional_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('-', ' '), scope: [:data, :attributes]
    end

    let(:id) { create(:customers_auth).id }
    let(:name) { 'name' }
    let(:capacity) { 2 }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/private/customers-auths/:id' do
    let(:id) { create(:customers_auth).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
