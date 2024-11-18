# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Service Types' do
  include_context :acceptance_admin_user
  let(:type) { 'service-types' }

  get '/api/rest/admin/service-types' do
    jsonapi_filters Api::Rest::Admin::ServiceTypeResource._allowed_filters

    before do
      create_list(:service_type, 2)
    end

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/service-types/:id' do
    let(:id) { create(:service_type).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/service-types' do
    parameter :type, 'Resource type (service-types)', scope: :data, required: true

    jsonapi_attributes(%i[name provisioning-class], %i[force-renew variables])

    let(:name) { 'name' }
    let(:'provisioning-class') { 'Billing::Provisioning::Logging' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/service-types/:id' do
    parameter :type, 'Resource type (service-types)', scope: :data, required: true
    parameter :id, 'Service type ID', scope: :data, required: true

    jsonapi_attributes(%i[name provisioning_class], [])

    let(:id) { create(:service_type).id }
    let(:name) { 'name' }
    let(:'provisioning-class') { 'Billing::Provisioning::Logging' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/service-types/:id' do
    let(:id) { create(:service_type).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
