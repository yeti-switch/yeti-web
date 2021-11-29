# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Authentication', document: :customer_v1 do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  post '/api/rest/customer/v1/auth' do
    parameter :login, 'Login', scope: :auth, required: true
    parameter :password, 'Password', scope: :auth, required: true
    parameter :cookie_auth, 'Cookie Auth', scope: :auth, required: false

    let(:login) { 'login' }
    let(:password) { 'password' }

    before { create :api_access, login: login, password: password }

    example_request 'get token' do
      explanation 'Pass received token to each request to private API as \'token\' parameter or \'Authorization\' header.'
      expect(status).to eq(201)
      response_json = JSON.parse(response_body, symbolize_names: true)
      expect(response_json).to match(jwt: be_present)
    end

    example_request 'get Cookie', { auth: { cookie_auth: true } } do
      explanation 'Pass received Set-Cookie header to each request to private API as \'Cookie\' header.'
      expect(status).to eq(201)
      expect(response_body).to be_blank
      expect(response_headers['set-cookie']).to be_present
    end
  end

  get '/api/rest/customer/v1/auth' do
    header 'Cookie', :auth_cookie

    include_context :customer_v1_cookie_helpers
    let(:auth_cookie) { build_customer_cookie(api_access.id, expiration: 1.minute.from_now) }
    let(:api_access) { create :api_access }

    example_request 'check auth cookie' do
      explanation 'auth cookie is valid and responds with new cookie'
      expect(status).to eq(200)
      expect(response_headers['set-cookie']).to be_present
    end
  end

  delete '/api/rest/customer/v1/auth' do
    example_request 'clear auth cookie' do
      explanation 'responds with cleared cookie'
      expect(status).to eq(204)
      expect(response_headers['set-cookie']).to match(/logout/)
    end
  end
end
