# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Routeset discriminators' do
  include_context :acceptance_admin_user
  let(:type) { 'routeset-discriminators' }

  get '/api/rest/admin/routeset-discriminators' do
    jsonapi_filters Api::Rest::Admin::RoutesetDiscriminatorResource._allowed_filters

    before { create_list(:routeset_discriminator, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/routeset-discriminators/:id' do
    let(:id) { create(:routeset_discriminator).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/routeset-discriminators' do
    parameter :type, 'Resource type (routeset-discriminators)', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:name) { 'name' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/routeset-discriminators/:id' do
    parameter :type, 'Resource type (routeset-discriminators)', scope: :data, required: true
    parameter :id, 'Routing group ID', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:id) { create(:routeset_discriminator).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/routeset-discriminators/:id' do
    let(:id) { create(:routeset_discriminator).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
