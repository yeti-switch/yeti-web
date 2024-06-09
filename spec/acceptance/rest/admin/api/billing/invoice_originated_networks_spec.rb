# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Invoice Originated Networks' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'invoice-originated-networks' }

  get '/api/rest/admin/billing/invoice-originated-networks' do
    jsonapi_filters Api::Rest::Admin::Billing::InvoiceOriginatedNetworkResource._allowed_filters

    before { create_list(:invoice_originated_network, 2, :filled) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/billing/invoice-originated-networks/:id' do
    let(:id) { create(:invoice_originated_network, :filled).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
