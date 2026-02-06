# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Transactions' do
  include_context :acceptance_admin_user

  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:api_access) { create :api_access }
  let(:contractor) { create(:contractor, customer: true) }

  let(:type) { 'transactions' }
  let!(:account_record) { create(:account, contractor: contractor) }

  post '/api/rest/admin/transactions' do
    parameter :type, 'Resource type (transactions)', scope: :data, required: true
    required_params = %i[amount]
    optional_params = %i[description]
    required_relations = %i[account]
    optional_relations = %i[service]

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relations, optional_relations)

    let(:amount) { '10.5' }
    let(:description) { 'Admin adjustment' }
    let(:account) { wrap_relationship(:accounts, account_record.id) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  get '/api/rest/admin/transactions' do
    jsonapi_filters Api::Rest::Admin::TransactionResource._allowed_filters

    before { create_list(:billing_transaction, 2, account: account_record) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/transactions/:id' do
    let(:id) { create(:billing_transaction, account: account_record).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
