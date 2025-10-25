# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Customer Portal Access Porfile', document: :customer_v1 do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:api_access) { create :api_access }
  let(:customer) { api_access.customer }
  include_context :customer_v1_cookie_helpers
  let(:auth_token) { build_customer_token(api_access.id, expiration: 1.minute.from_now) }
  let(:type) { 'customer-portal-access-profile' }

  get '/api/rest/customer/v1/customer-portal-access-profile' do
    example_request 'get current profile' do
      expect(status).to eq(200)
    end
  end
end
