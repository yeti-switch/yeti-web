# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Invoice Originated Destinations' do
  include_context :acceptance_admin_user
  let(:type) { 'invoice-originated-destinations' }

  get '/api/rest/admin/invoice-originated-destinations' do
    jsonapi_filters Api::Rest::Admin::InvoiceOriginatedDestinationResource._allowed_filters

    before { create_list(:invoice_originated_destination, 2, :filled) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/invoice-originated-destinations/:id' do
    let(:id) { create(:invoice_originated_destination, :filled).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
