require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Accounts' do
  header 'Accept', 'application/json'

  post '/api/rest/private/auth' do
    parameter :username, 'Login', scope: :auth, requred: true
    parameter :password, 'Password', scope: :auth, requred: true

    let(:username) { 'admin' }
    let(:password) { 'password' }

    before { create :admin_user, username: username, password: password }

    example_request 'get token' do
      expect(status).to eq(201)
    end
  end
end
