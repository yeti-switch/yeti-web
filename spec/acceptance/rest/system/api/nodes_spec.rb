# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'System Nodes' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'

  get '/api/rest/system/nodes' do
    before { create_list(:node, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end
end
