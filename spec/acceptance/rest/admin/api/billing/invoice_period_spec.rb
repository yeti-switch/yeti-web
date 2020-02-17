# frozen_string_literal: true

require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Invoice period' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'invoice-periods' }

  get '/api/rest/admin/billing/invoice-period' do
    jsonapi_filters Api::Rest::Admin::Billing::InvoicePeriodResource._allowed_filters

    before do
      Billing::InvoicePeriod.create(name: 'Weekly')
    end
    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/billing/invoice-period/:id' do
    let(:id) { Billing::InvoicePeriod.create(name: 'Weekly').id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/billing/invoice-period' do
    parameter :type, 'Resource type (invoice-periods)', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:name) { 'Daily' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/billing/invoice-period/:id' do
    parameter :type, 'Resource type (invoice-periods)', scope: :data, required: true
    parameter :id, 'Invoice period ID', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:id) { Billing::InvoicePeriod.create(name: 'Weekly').id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/billing/invoice-period/:id' do
    let(:id) { Billing::InvoicePeriod.create(name: 'Weekly').id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
