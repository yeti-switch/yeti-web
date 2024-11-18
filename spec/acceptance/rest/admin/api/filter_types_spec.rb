# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Filter types' do
  include_context :acceptance_admin_user
  let(:type) { 'filter-types' }

  get '/api/rest/admin/filter-types' do
    jsonapi_filters Api::Rest::Admin::FilterTypeResource._allowed_filters

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/filter-types/:id' do
    let(:id) { FilterType.first.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
