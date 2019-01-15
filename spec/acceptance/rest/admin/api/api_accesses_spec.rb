# frozen_string_literal: true

require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'ApiAccesses' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'api-accesses' }

  required_params = %i[customer-id login password]
  optional_params = %i[account-ids allowed-ips]

  get '/api/rest/admin/api-accesses' do
    before { create_list(:api_access, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/api-accesses/:id' do
    let(:id) { create(:api_access).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/api-accesses' do
    parameter :type, 'Resource type (api-accesses)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)

    let!(:account) { create(:account) }

    let(:'customer-id') { account.contractor.id }
    let(:login) { 'login' }
    let(:password) { '111111' }
    let(:'account-ids') { [account.id] }
    let(:'allowed-ips') { ['127.0.0.1', '127.0.0.2'] }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/api-accesses/:id' do
    parameter :type, 'Resource type (api-accesses)', scope: :data, required: true
    parameter :id, 'ApiAccess ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)

    let!(:account) { create(:account) }

    let(:id) { create(:api_access, customer: account.contractor).id }
    let(:login) { 'login' }
    let(:password) { '111111' }
    let(:'account-ids') { [account.id] }
    let(:'allowed-ips') { ['127.0.0.1', '127.0.0.2'] }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/api-accesses/:id' do
    let(:id) { create(:api_access).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
