# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Invoice Service Data' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'invoice-service-data' }

  get '/api/rest/admin/invoice-service-data' do
    jsonapi_filters Api::Rest::Admin::InvoiceServiceDatumResource._allowed_filters

    before { create_list(:invoice_service_data, 2, :filled) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/invoice-service-data/:id' do
    let(:id) { create(:invoice_service_data, :filled).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
