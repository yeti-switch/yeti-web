# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Smtp connections' do
  include_context :acceptance_admin_user
  let(:type) { 'smtp-connections' }

  required_params = %i[name host port from-address]
  optional_params = %i[auth-user auth-password global]

  get '/api/rest/admin/smtp-connections' do
    jsonapi_filters Api::Rest::Admin::SmtpConnectionResource._allowed_filters

    before { create_list(:smtp_connection, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/smtp-connections/:id' do
    let(:id) { create(:smtp_connection).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/smtp-connections' do
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

  put '/api/rest/admin/smtp-connections/:id' do
    parameter :type, 'Resource type (smtp-connections)', scope: :data, required: true
    parameter :id, 'Smtp connection ID', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:id) { create(:smtp_connection).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/smtp-connections/:id' do
    let(:id) { create(:smtp_connection).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
