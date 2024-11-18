# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Phone Systems session', document: :customer_v1 do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:api_access) { create :api_access }
  let(:customer) { api_access.customer }
  let!(:account) { create(:account, contractor: customer) }
  include_context :customer_v1_cookie_helpers
  include_context :stub_request_to_create_phone_systems_session
  let(:service_id) { service_relation.id }
  let(:auth_token) { build_customer_token(api_access.id, expiration: 1.minute.from_now) }
  let(:type) { 'phone-systems-sessions' }

  post '/api/rest/customer/v1/phone-systems-sessions' do
    parameter :type, scope: :data, required: true
    jsonapi_attribute :service

    let(:service) { service_relation.uuid }
    let(:service_type_attrs) do
      {
        variables: {
          endpoint: phone_systems_base_url,
          username: 'test',
          password: 'test',
          # Attributes for Customer on the phone.systems side
          attributes: {
            name: 'John Johnson',
            language: 'EN',
            trm_mode: 'operator',
            capacity_limit: 10,
            sip_account_limit: 5
          }
        }
      }
    end
    let(:service_type) { FactoryBot.create(:service_type, service_type_attrs) }
    let(:service_relation_attrs) { { type: service_type, account:, variables: { attributes: { name: 'John Doe' } } } }
    let(:service_relation) { FactoryBot.create(:service, service_relation_attrs) }

    before { stub_request_to_create_phone_systems_session }

    example_request 'create new phone.systems session' do
      expect(status).to eq(201)
      expect(stub_request_to_create_phone_systems_session).to have_been_requested
    end
  end
end
