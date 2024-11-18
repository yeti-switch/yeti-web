# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Diversion policies' do
  include_context :acceptance_admin_user
  let(:type) { 'diversion-policies' }

  get '/api/rest/admin/diversion-policies' do
    jsonapi_filters Api::Rest::Admin::DiversionPolicyResource._allowed_filters

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/diversion-policies/:id' do
    let(:id) { DiversionPolicy.first.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
