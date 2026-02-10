# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'DNS Zones' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'

  get '/api/rest/dns/zones' do
    before { create_list(:dns_zone, 2) }

    jsonapi_filters Api::Rest::Dns::ZoneResource._allowed_filters
    parameter :sort, 'Sort by comma-separated attributes: id,name,serial', required: false

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/dns/zones/:id/zonefile' do
    header 'Accept', 'text/dns'
    header 'Content-Type', 'text/dns'
    parameter :id, 'DNS zone ID', required: true

    let(:id) do
      zone = create(:dns_zone, name: 'example.com')
      create(:dns_record, zone: zone, contractor: nil, name: '@', record_type: 'A', content: '192.0.2.1')
      zone.id
    end

    example_request 'get zonefile' do
      expect(status).to eq(200)
      expect(response_headers['content-type']).to start_with('text/dns')
    end
  end
end
