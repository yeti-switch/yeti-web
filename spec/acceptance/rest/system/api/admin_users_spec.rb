require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'System Admin Users' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'

  get '/api/rest/system/admin_users' do
    before { create_list(:admin_user, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

end
