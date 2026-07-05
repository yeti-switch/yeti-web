# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Invoice template' do
  include_context :acceptance_admin_user
  let(:type) { 'invoice-templates' }

  get '/api/rest/admin/invoice-template' do
    jsonapi_filters Api::Rest::Admin::InvoiceTemplateResource._allowed_filters

    before { create_list(:invoice_template, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/invoice-template/:id' do
    let(:id) { create(:invoice_template).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/invoice-template' do
    parameter :type, 'Resource type (invoice-templates)', scope: :data, required: true

    jsonapi_attributes(%i[name], [])
    # html_template dasherizes to the "html-template" param, whose value
    # rspec_api_documentation looks up by that (dashed) name; point it back at
    # the underscored let so the value is actually sent (otherwise it arrives
    # blank and the required validation returns 422).
    jsonapi_attribute(:html_template, required: true, method: :html_template)

    let(:name) { 'Daily' }
    let(:html_template) { '<p>{{ invoice.reference }}</p>' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/invoice-template/:id' do
    parameter :type, 'Resource type (invoice-templates)', scope: :data, required: true
    parameter :id, 'Invoice template ID', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:id) { create(:invoice_template).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/invoice-template/:id' do
    let(:id) { create(:invoice_template).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
