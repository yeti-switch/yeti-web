# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Destination next rates' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'destination-next-rates' }
  let(:destination) { create(:destination) }
  let(:destination_id) { destination.id }

  required_params = %i[
    next-rate initial-rate initial-interval next-interval connect-fee apply-time applied
  ]
  optional_params = %i[external-id]
  required_relationships = %i[destination]

  get '/api/rest/admin/destination-next-rates' do
    jsonapi_filters Api::Rest::Admin::DestinationNextRateResource._allowed_filters

    before { create_list(:destination_next_rate, 2, destination: destination) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/destination-next-rates/:id' do
    let(:id) { create(:destination_next_rate, destination: destination).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/destination-next-rates' do
    parameter :type, 'Resource type (destinations-next-rates)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, [])

    let(:applied) { false }
    let(:destination) { wrap_relationship(:destinations, create(:destination).id) }
    let(:'apply-time') { 1.hour.from_now }
    let(:'connect-fee') { 0 }
    let(:'initial-interval') { 60 }
    let(:'next-interval') { 60 }
    let(:'initial-rate') { 0.0 }
    let(:'next-rate') { 0.0 }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/destination-next-rates/:id' do
    parameter :type, 'Resource type (destinations-next-rates)', scope: :data, required: true
    parameter :id, 'Destination next rate ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)

    let(:id) { create(:destination_next_rate, destination: destination).id }
    let(:'initial-rate') { 22 }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/destination-next-rates/:id' do
    let(:id) { create(:destination_next_rate).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
