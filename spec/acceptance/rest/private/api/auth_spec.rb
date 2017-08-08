require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Authentication' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  post '/api/rest/private/auth' do
    parameter :username, 'Login', scope: :auth, requred: true
    parameter :password, 'Password', scope: :auth, requred: true

    let(:username) { 'admin' }
    let(:password) { 'password' }

    before { create :admin_user, username: username, password: password }

    example_request 'get token' do
      explanation 'Pass received token to each request to private API as \'token\' parameter or \'Authorization\' header.'
      expect(status).to eq(201)
    end
  end
end
