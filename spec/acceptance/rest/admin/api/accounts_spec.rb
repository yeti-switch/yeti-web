# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Accounts' do
  include_context :acceptance_admin_user
  let(:type) { 'accounts' }

  required_params = %i[name min-balance max-balance]
  optional_params = %i[
    vat origination-capacity termination-capacity total-capacity
    send-invoices-to
    external-id
    balance-low-threshold balance-high-threshold send-balance-notifications-to
    invoice-period-id timezone
  ]

  required_relationships = %i[contractor]
  optional_relationships = %i[invoice-template]

  get '/api/rest/admin/accounts' do
    jsonapi_filters Api::Rest::Admin::AccountResource._allowed_filters

    before { create_list(:account, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/accounts/:id' do
    let(:id) { create(:account).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/accounts' do
    parameter :type, 'Resource type (accounts)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:name) { 'name' }
    let(:'min-balance') { 1 }
    let(:'max-balance') { 10 }
    let(:'balance-low-threshold') { 90 }
    let(:'balance-high-threshold') { 95 }
    let(:'send-balance-notifications-to') { Billing::Contact.collection.map(&:id) }
    let(:vat) { 11 }
    let(:'origination-capacity') { 100 }
    let(:'termination-capacity') { 110 }
    let(:'total-capacity') { 100 }
    let(:timezone) { 'Europe/Kyiv' }

    let(:contractor) { wrap_relationship(:contractors, create(:contractor, vendor: true).id) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/accounts/:id' do
    parameter :type, 'Resource type (accounts)', scope: :data, required: true
    parameter :id, 'Account ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:id) { create(:account).id }
    let(:name) { 'name' }
    let(:'max-balance') { 20 }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/accounts/:id' do
    let(:id) { create(:account).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
