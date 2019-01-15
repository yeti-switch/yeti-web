# frozen_string_literal: true

require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Smtp connections' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'smtp-connections' }

  required_params = %i[name host port from-address]
  optional_params = %i[auth-user auth-password global]

  get '/api/rest/admin/system/smtp-connections' do
    before { create_list(:smtp_connection, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/system/smtp-connections/:id' do
    let(:id) { create(:smtp_connection).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/system/smtp-connections' do
    parameter :type, 'Resource type (smtp-connections)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)

    let(:name) { 'name' }
    let(:port) { 25 }
    let(:host) { 'host' }
    let(:'from-address') { 'address@email.com' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/system/smtp-connections/:id' do
    parameter :type, 'Resource type (smtp-connections)', scope: :data, required: true
    parameter :id, 'Smtp connection ID', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:id) { create(:smtp_connection).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/system/smtp-connections/:id' do
    let(:id) { create(:smtp_connection).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
