# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Payments' do
  include_context :acceptance_admin_user
  let(:type) { 'payments' }

  get '/api/rest/admin/payments' do
    jsonapi_filters Api::Rest::Admin::PaymentResource._allowed_filters

    before { create_list(:payment, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/payments/:id' do
    let(:id) { create(:payment).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/payments' do
    parameter :type, 'Resource type (payments)', scope: :data, required: true

    jsonapi_attributes([:amount], [:notes])
    jsonapi_relationships([:account], [])

    let(:amount) { 10 }
    let(:account) { wrap_relationship(:accounts, create(:account).id) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end
end
