# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Cdrs', document: :customer_v1 do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:api_access) { create(:api_access, allow_listen_recording: true) }
  let(:customer) { api_access.customer }
  include_context :customer_v1_cookie_helpers
  let(:auth_token) { build_customer_token(api_access.id, expiration: 1.minute.from_now) }
  let(:type) { 'cdrs' }

  let(:customers_auth) do
    create(:customers_auth, customer_id: customer.id)
  end

  before do
    # link customer and account
    customers_auth.account.update(contractor_id: customer.id)
  end

  get '/api/rest/customer/v1/cdrs' do
    jsonapi_filters Api::Rest::Customer::V1::CdrResource._allowed_filters

    before { create_list(:cdr, 2, customer_acc: customers_auth.account) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/customer/v1/cdrs/:id' do
    let(:id) { create(:cdr, customer_acc: customers_auth.account).id.to_s }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/customer/v1/cdrs/:id/rec' do
    let(:id) { create(:cdr, customer_acc: customers_auth.account, audio_recorded: true).id.to_s }

    example_request 'get rec' do
      expect(status).to eq(200)
    end
  end
end
