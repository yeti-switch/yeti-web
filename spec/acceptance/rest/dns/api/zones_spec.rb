# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'DNS Zones' do
  include_context :acceptance_admin_user

  get '/api/rest/dns/zones' do
    before { create_list(:dns_zone, 2) }

    jsonapi_filters Api::Rest::Dns::ZoneResource._allowed_filters
    parameter :sort, 'Sort by comma-separated attributes: id,name,serial', required: false

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end
end
