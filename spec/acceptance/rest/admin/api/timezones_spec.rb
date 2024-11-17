# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Timezones' do
  include_context :acceptance_admin_user
  let(:type) { 'timezones' }

  get '/api/rest/admin/timezones' do
    jsonapi_filters Api::Rest::Admin::TimezoneResource._allowed_filters

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/timezones/:id' do
    let(:id) { System::Timezone.first.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
