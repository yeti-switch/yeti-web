# frozen_string_literal: true

require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Sensors' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'sensors' }

  required_params = %i[name mode-id target-ip source-ip]
  optional_params = %i[source-interface target-mac use-routing]

  get '/api/rest/admin/system/sensors' do
    jsonapi_filters Api::Rest::Admin::System::SensorResource._allowed_filters

    before { create_list(:sensor, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/system/sensors/:id' do
    let(:id) { create(:sensor).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/system/sensors' do
    parameter :type, 'Resource type (sensors)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)

    let(:name) { 'name' }
    let(:'mode-id') { 1 }
    let(:'source-ip') { '192.168.0.1' }
    let(:'target-ip') { '192.168.0.2' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/system/sensors/:id' do
    parameter :type, 'Resource type (sensors)', scope: :data, required: true
    parameter :id, 'Sensor ID', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:id) { create(:sensor).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/system/sensors/:id' do
    let(:id) { create(:sensor).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
