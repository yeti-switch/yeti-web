# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Package Counters' do
  include_context :acceptance_admin_user
  let(:type) { 'package-counters' }

  get '/api/rest/admin/package-counters' do
    jsonapi_filters Api::Rest::Admin::PackageCounterResource._allowed_filters

    before do
      create_list(:billing_package_counter, 2)
    end

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/package-counters/:id' do
    let(:id) { create(:billing_package_counter).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
