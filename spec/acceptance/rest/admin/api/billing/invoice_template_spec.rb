# frozen_string_literal: true

require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Invoice template' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'invoice-templates' }

  get '/api/rest/admin/billing/invoice-template' do
    before { create_list(:invoice_template, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/billing/invoice-template/:id' do
    let(:id) { create(:invoice_template).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/billing/invoice-template' do
    parameter :type, 'Resource type (invoice-templates)', scope: :data, required: true

    jsonapi_attributes(%i[name filename], [])

    let(:name) { 'Daily' }
    let(:filename) { 'filename.odt' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/billing/invoice-template/:id' do
    parameter :type, 'Resource type (invoice-templates)', scope: :data, required: true
    parameter :id, 'Invoice template ID', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:id) { create(:invoice_template).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/billing/invoice-template/:id' do
    let(:id) { create(:invoice_template).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
