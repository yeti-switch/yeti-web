# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'CallAuth', document: :customer_v1 do
  include_context :customer_v1_cookie_helpers

  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :auth_token

  let(:customer_attrs) { {} }
  let!(:customer) { FactoryBot.create(:customer, customer_attrs) }
  let(:gateway_attrs) { { contractor: customer, incoming_auth_allow_jwt: true } }
  let!(:gateway) { FactoryBot.create(:gateway, gateway_attrs) }
  let(:api_access_attrs) { { allow_listen_recording: true, provision_gateway_id: gateway.id, login: 'admin', password: '1234567890' } }
  let!(:api_access) { create(:api_access, api_access_attrs) }
  let(:auth_token) { build_customer_token(api_access.id, expiration: 1.minute.from_now) }

  post '/api/rest/customer/v1/call-auth' do
    example_request 'Receive Gayeway JWT token' do
      explanation 'Example of decoded JWT payload: ' \
                  'gid: gateway.uuid, ' \
                  'iat: current timestamp(in UTC timezone), ' \
                  'exp: current timestamp(in UTC timezone) + call_jwt_lifetime seconds'

      response_json = JSON.parse(response_body, symbolize_names: true)
      expect(response_json[:errors]).to eq nil
      expect(response_json).to match(jwt: be_present)
    end
  end

  post '/api/rest/customer/v1/call-auth' do
    let(:api_access_attrs) { super().merge provision_gateway_id: nil }

    example_request 'Receive 500 validation error (Gateway is not found)' do
      expect(status).to eq(500)
      response_json = JSON.parse(response_body, symbolize_names: true)
      expect(response_json[:errors]).to contain_exactly code: '500', detail: 'Provisioning Gateway is not found.', status: '500', title: 'Invalid request'
    end
  end

  post '/api/rest/customer/v1/call-auth' do
    let(:gateway_attrs) { super().merge incoming_auth_allow_jwt: false }

    example_request 'Receive 500 validation error (Incoming JWT is disabled for Gateway)' do
      expect(status).to eq(500)
      response_json = JSON.parse(response_body, symbolize_names: true)
      expect(response_json[:errors]).to contain_exactly code: '500', detail: 'Incoming JWT is disabled for Provisioning Gateway.', status: '500', title: 'Invalid request'
    end
  end
end
