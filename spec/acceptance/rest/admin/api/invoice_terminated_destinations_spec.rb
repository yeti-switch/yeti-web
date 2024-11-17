# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Invoice Terminated Destinations' do
  include_context :acceptance_admin_user
  let(:type) { 'invoice-terminated-destinations' }

  get '/api/rest/admin/invoice-terminated-destinations' do
    jsonapi_filters Api::Rest::Admin::InvoiceTerminatedDestinationResource._allowed_filters

    before { create_list(:invoice_terminated_destination, 2, :filled) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/invoice-terminated-destinations/:id' do
    let(:id) { create(:invoice_terminated_destination, :filled).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
