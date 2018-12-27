require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'System IP access' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'

  get '/api/rest/system/ip_access' do
    before { create_list(:customers_auth, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

end
