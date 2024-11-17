# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Sensor levels' do
  include_context :acceptance_admin_user
  let(:type) { 'sensor-levels' }

  get '/api/rest/admin/sensor-levels' do
    jsonapi_filters Api::Rest::Admin::SensorLevelResource._allowed_filters

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/sensor-levels/:id' do
    let(:id) { System::SensorLevel.first.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
