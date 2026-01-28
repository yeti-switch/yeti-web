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
  let!(:account) { create(:account, contractor: contractor) }

  get '/api/rest/admin/transactions' do
    jsonapi_filters Api::Rest::Admin::TransactionResource._allowed_filters

    before { create_list(:billing_transaction, 2, account: account) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/transactions/:id' do
    let(:id) { create(:billing_transaction, account: account).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

end
