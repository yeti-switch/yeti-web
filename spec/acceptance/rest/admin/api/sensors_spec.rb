# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Sensors' do
  include_context :acceptance_admin_user
  let(:type) { 'sensors' }

  required_params = %i[name mode-id target-ip source-ip]
  optional_params = %i[source-interface target-mac use-routing]

  get '/api/rest/admin/sensors' do
    jsonapi_filters Api::Rest::Admin::SensorResource._allowed_filters

    before { create_list(:sensor, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/sensors/:id' do
    let(:id) { create(:sensor).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/sensors' do
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

  put '/api/rest/admin/sensors/:id' do
    parameter :type, 'Resource type (sensors)', scope: :data, required: true
    parameter :id, 'Sensor ID', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:id) { create(:sensor).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/sensors/:id' do
    let(:id) { create(:sensor).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
