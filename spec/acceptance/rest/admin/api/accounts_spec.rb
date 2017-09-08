require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Accounts' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'accounts' }

  required_params = %i(name min-balance max-balance)
  optional_params = %i(origination-capacity termination-capacity send-invoices-to)

  required_relationships = %i(contractor timezone)
  optional_relationships = %i(
    customer-invoice-period vendor-invoice-period customer-invoice-template vendor-invoice-template
  )

  get '/api/rest/admin/accounts' do
    before { create_list(:account, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/accounts/:id' do
    let(:id) { create(:account).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/accounts' do
    parameter :type, 'Resource type (accounts)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:name) { 'name' }
    let(:'min-balance') { 1 }
    let(:'max-balance') { 10 }
    let(:timezone) { wrap_relationship(:'timezones', 1) }
    let(:contractor) { wrap_relationship(:contractors, create(:contractor, vendor: true).id) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/accounts/:id' do
    parameter :type, 'Resource type (accounts)', scope: :data, required: true
    parameter :id, 'Account ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:id) { create(:account).id }
    let(:name) { 'name' }
    let(:'max-balance') { 20 }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/accounts/:id' do
    let(:id) { create(:account).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
