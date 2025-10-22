# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'OutgoingNumberlistItem', document: :customer_v1 do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let!(:nl) { create(:numberlist, name: 'test', mode_id: Routing::Numberlist::MODE_STRICT) }
  let!(:nli) { create(:numberlist_item, numberlist_id: nl.id, key: 'test-key') }

  let(:api_access) { create(:api_access, allow_outgoing_numberlists_ids: [nl.id]) }
  let(:customer) { api_access.customer }
  include_context :customer_v1_cookie_helpers
  let(:auth_token) { build_customer_token(api_access.id, expiration: 1.minute.from_now) }
  let(:type) { 'outgoing-numberlists' }

  let!(:customers_auth) do
    create(:customers_auth, customer_id: customer.id, dst_numberlist_id: nl.id)
  end

  get '/api/rest/customer/v1/outgoing-numberlist-items' do
    jsonapi_filters Api::Rest::Customer::V1::OutgoingNumberlistItemResource._allowed_filters

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/customer/v1/outgoing-numberlist-items/:id' do
    let(:id) { nli.reload.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
