# frozen_string_literal: true

require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Dialpeer next rates' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'dialpeer-next-rates' }
  let(:dialpeer) { create(:dialpeer) }
  let(:dialpeer_id) { dialpeer.id }

  required_params = %i[
    next-rate initial-rate initial-interval next-interval connect-fee apply-time applied
  ]
  optional_params = %i[external-id]
  required_relationships = %i[dialpeer]

  get '/api/rest/admin/dialpeer-next-rates' do
    jsonapi_filters Api::Rest::Admin::DialpeerNextRateResource._allowed_filters

    before { create_list(:dialpeer_next_rate, 2, dialpeer: dialpeer) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/dialpeer-next-rates/:id' do
    let(:id) { create(:dialpeer_next_rate, dialpeer: dialpeer).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/dialpeer-next-rates' do
    parameter :type, 'Resource type (dialpeers-next-rates)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, [])

    let(:applied) { false }
    let(:dialpeer) { wrap_relationship(:dialpeers, create(:dialpeer).id) }
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

  put '/api/rest/admin/dialpeer-next-rates/:id' do
    parameter :type, 'Resource type (dialpeers-next-rates)', scope: :data, required: true
    parameter :id, 'Dialpeer next rate ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)

    let(:id) { create(:dialpeer_next_rate, dialpeer: dialpeer).id }
    let(:'initial-rate') { 22 }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/dialpeer-next-rates/:id' do
    let(:id) { create(:dialpeer_next_rate).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
