# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Services' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'services' }

  get '/api/rest/admin/billing/services' do
    jsonapi_filters Api::Rest::Admin::Billing::ServiceResource._allowed_filters

    before do
      create_list(:service, 2)
    end

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/billing/services/:id' do
    let(:id) { create(:service).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/billing/services' do
    parameter :type, 'Resource type (services)', scope: :data, required: true

    jsonapi_attributes(%i[name initial-price renew-price], %i[renew-at renew-period variables])
    jsonapi_relationships(%i[account service-type], [])

    let(:name) { 'name' }
    let(:'initial-price') { 1.23 }
    let(:'renew-price') { 3.24 }
    let(:account) { wrap_relationship('accounts', account_record.id.to_s) }
    let!(:account_record) { create(:account) }
    let(:'service-type') { wrap_relationship('service-types', service_type_record.id.to_s) }
    let!(:service_type_record) { create(:service_type) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/billing/services/:id' do
    parameter :type, 'Resource type (services)', scope: :data, required: true
    parameter :id, 'Service type ID', scope: :data, required: true

    jsonapi_attributes(%i[name renew-price variables], [])

    let(:id) { create(:service).id }
    let(:name) { 'name' }
    let(:'renew-price') { 123.45 }
    let(:variables) { { foo: 'bar' } }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end
end
