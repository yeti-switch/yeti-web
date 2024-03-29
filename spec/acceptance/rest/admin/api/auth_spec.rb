# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Authentication' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  post '/api/rest/admin/auth' do
    parameter :username, 'Login', scope: :auth, required: true
    parameter :password, 'Password', scope: :auth, required: true

    let(:username) { 'test-admin' }
    let(:password) { 'password' }

    before { create :admin_user, username: username, password: password }

    example_request 'get token' do
      explanation 'Pass received token to each request to private API as \'token\' parameter or \'Authorization\' header.'
      expect(status).to eq(201)
    end
  end
end
