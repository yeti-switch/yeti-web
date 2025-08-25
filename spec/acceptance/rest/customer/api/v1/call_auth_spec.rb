# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Call Authentication', document: :customer_v1 do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  post '/api/rest/customer/v1/call-auth' do

    before { create :api_access }

    example_request 'get token' do
      explanation 'Pass received token to each request to private API as \'token\' parameter or \'Authorization\' header.'
      expect(status).to eq(201)
      response_json = JSON.parse(response_body, symbolize_names: true)
      expect(response_json).to match(jwt: be_present)
    end
  end
end
