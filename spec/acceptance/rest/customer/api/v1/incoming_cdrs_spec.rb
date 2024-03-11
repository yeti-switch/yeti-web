# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'IncomingCdrs', document: :customer_v1 do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:api_access) { create(:api_access, allow_listen_recording: true) }
  let(:vendor) { api_access.customer }
  include_context :customer_v1_cookie_helpers
  let(:auth_token) { build_customer_token(api_access.id, expiration: 1.minute.from_now) }
  let(:type) { 'incoming-cdrs' }

  let(:vendor_acc) do
    create(:account, contractor_id: vendor.id)
  end

  get '/api/rest/customer/v1/incoming-cdrs' do
    jsonapi_filters Api::Rest::Customer::V1::IncomingCdrResource._allowed_filters

    before { create_list(:cdr, 2, vendor_id: vendor.id, vendor_acc_id: vendor_acc.id) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/customer/v1/incoming-cdrs/:id' do
    let(:id) { create(:cdr, vendor_id: vendor.id, vendor_acc_id: vendor_acc.id).uuid }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/customer/v1/incoming-cdrs/:id/rec' do
    let(:id) { create(:cdr, vendor_id: vendor.id, vendor_acc_id: vendor_acc.id, audio_recorded: true).uuid }

    example_request 'get rec' do
      expect(status).to eq(200)
    end
  end
end
