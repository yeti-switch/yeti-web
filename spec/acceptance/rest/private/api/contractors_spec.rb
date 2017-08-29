require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Contractors' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'contractors' }

  required_params = %i(name vendor customer)
  optional_params = %i(enabled description address phones)
  optional_relationships = %i(smtp-connection)

  get '/api/rest/private/contractors' do
    before { create_list(:contractor, 2, vendor: true) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/contractors/:id' do
    let(:id) { create(:contractor, vendor: true).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/contractors' do
    parameter :type, 'Resource type (contractors)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships([], optional_relationships)

    let(:name) { 'Contractor name' }
    let(:vendor) { true }
    let(:customer) { true }
    let(:enabled) { true }
    let(:description) { 'Description' }
    let(:address) { 'Address' }
    let(:phones) { 'Phones' }
    let(:'smtp-сonnection') { wrap_relationship(:'smtp-connections', create(:smtp_connection).id ) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/contractors/:id' do
    parameter :type, 'Resource type (contractors)', scope: :data, required: true
    parameter :id, 'Contractor ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships([], optional_relationships)

    let(:id) { create(:contractor, vendor: true).id }
    let(:name) { 'name' }
    let(:customer) { true }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/private/contractors/:id' do
    let(:id) { create(:contractor, vendor: true).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
