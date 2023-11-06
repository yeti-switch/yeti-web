# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Invoices', document: :customer_v1 do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:api_access) { create :api_access }
  let(:customer) { api_access.customer }
  include_context :customer_v1_cookie_helpers
  let(:auth_token) { build_customer_token(api_access.id, expiration: 1.minute.from_now) }
  let(:type) { 'invoices' }
  let!(:account) { create(:account, contractor: customer) }

  get '/api/rest/customer/v1/invoices' do
    jsonapi_filters Api::Rest::Customer::V1::InvoiceResource._allowed_filters

    before do
      create_list(:invoice, 2, :manual, :approved, account: account)
    end

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/customer/v1/invoices/:id' do
    let(:id) do
      create(:invoice, :manual, :approved, account: account).reload.uuid
    end

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
