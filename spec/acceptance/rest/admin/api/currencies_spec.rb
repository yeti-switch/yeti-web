# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Currencies' do
  include_context :acceptance_admin_user
  let(:type) { 'currencies' }

  get '/api/rest/admin/currencies' do
    jsonapi_filters Api::Rest::Admin::CurrencyResource._allowed_filters

    before { create_list(:currency, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/currencies/:id' do
    let(:id) { create(:currency).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/currencies' do
    parameter :type, 'Resource type (currencies)', scope: :data, required: true

    jsonapi_attributes(%i[name rate], [])

    let(:name) { 'EUR' }
    let(:rate) { 1.2 }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/currencies/:id' do
    parameter :type, 'Resource type (currencies)', scope: :data, required: true
    parameter :id, 'Currency ID', scope: :data, required: true

    jsonapi_attributes(%i[name rate], [])

    let(:id) { create(:currency).id }
    let(:name) { 'GBP' }
    let(:rate) { 1.5 }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/currencies/:id' do
    let(:id) { create(:currency).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
