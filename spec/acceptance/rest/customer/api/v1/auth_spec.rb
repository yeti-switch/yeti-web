# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Authentication', document: :customer_v1 do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  post '/api/rest/customer/v1/auth' do
    parameter :login, 'Login', scope: :auth, required: true
    parameter :password, 'Password', scope: :auth, required: true

    let(:login) { 'login' }
    let(:password) { 'password' }

    before { create :api_access, login: login, password: password }

    example_request 'get token' do
      explanation 'Pass received token to each request to private API as \'token\' parameter or \'Authorization\' header.'
      expect(status).to eq(201)
    end
  end

  get '/api/rest/customer/v1/auth' do
    header 'Cookie', :auth_cookie

    include_context :customer_v1_cookie_helpers
    let(:auth_cookie) { build_customer_cookie(api_access.id, expiration: 1.minute.from_now) }
    let(:api_access) { create :api_access }

    example_request 'check auth cookie' do
      explanation 'auth cookie is valid'
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/customer/v1/auth' do
    example_request 'respond with logout cookie' do
      explanation 'logged out'
      expect(status).to eq(204)
    end
  end
end
