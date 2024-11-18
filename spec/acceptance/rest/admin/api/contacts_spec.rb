# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Contacts' do
  include_context :acceptance_admin_user
  let(:type) { 'contacts' }

  required_params = %i[email]

  optional_params = %i[notes]

  required_relationships = %i[]
  optional_relationships = %i[contractor]

  get '/api/rest/admin/contacts' do
    jsonapi_filters Api::Rest::Admin::ContactResource._allowed_filters

    before { create_list(:contact, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/contacts/:id' do
    let(:id) { create(:contact).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/contacts' do
    parameter :type, 'Resource type (contacts)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:new_customer) { create :customer }

    let(:email) { 'some@mail.com' }
    let(:notes) { 'Text here...' }
    let(:customer) { wrap_relationship(:contractors, new_customer.id) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/contacts/:id' do
    parameter :type, 'Resource type (contacts)', scope: :data, required: true
    parameter :id, 'Contact ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)

    let(:id) { create(:contact).id }
    let(:email) { 'another@mail.com' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/contacts/:id' do
    let(:id) { create(:contact).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
