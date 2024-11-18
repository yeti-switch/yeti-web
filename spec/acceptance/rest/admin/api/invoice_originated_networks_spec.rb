# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Invoice Originated Networks' do
  include_context :acceptance_admin_user
  let(:type) { 'invoice-originated-networks' }

  get '/api/rest/admin/invoice-originated-networks' do
    jsonapi_filters Api::Rest::Admin::InvoiceOriginatedNetworkResource._allowed_filters

    before { create_list(:invoice_originated_network, 2, :filled) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/invoice-originated-networks/:id' do
    let(:id) { create(:invoice_originated_network, :filled).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
