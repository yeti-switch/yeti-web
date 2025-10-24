# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'OutgoingNumberlistItem', document: :customer_v1 do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let!(:nl) { create(:numberlist, name: 'test', mode_id: Routing::Numberlist::MODE_STRICT) }
  let!(:nli) { create(:numberlist_item, numberlist_id: nl.id, key: 'test-key') }

  let(:api_access) { create(:api_access, allow_outgoing_numberlists_ids: [nl.id]) }
  let!(:api_comf) { create(:api_log_config, controller: 'Api::Rest::Customer::V1::OutgoingNumberlistItemsController') }
  let(:customer) { api_access.customer }
  include_context :customer_v1_cookie_helpers
  let(:auth_token) { build_customer_token(api_access.id, expiration: 1.minute.from_now) }
  let(:type) { 'outgoing-numberlist-items' }

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

  post '/api/rest/customer/v1/outgoing-numberlist-items' do
    parameter :type, 'Resource type (outgoing-numberlist-items)', scope: :data, required: true

    jsonapi_attributes(%i[key action-id], [])
    jsonapi_relationships([:'outgoing-numberlist'], [])

    let(:key) { 'key' }
    let(:'action-id') { 2 }
    let(:'outgoing-numberlist') { wrap_relationship(:'outgoing-numberlists', nl.id.to_s) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/customer/v1/outgoing-numberlist-items/:id' do
    parameter :type, 'Resource type (outgoing-numberlist-items)', scope: :data, required: true
    parameter :id, 'Item ID', scope: :data, required: true

    jsonapi_attributes(%i[key action-id], [])

    let(:id) { nli.id }
    let(:key) { 'key' }
    let(:'action-id') { 2 }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/customer/v1/outgoing-numberlist-items/:id' do
    let(:id) { nli.reload.id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
