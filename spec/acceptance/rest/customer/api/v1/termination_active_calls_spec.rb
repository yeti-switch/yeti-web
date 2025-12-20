# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Termination Active Calls', document: :customer_v1 do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let!(:customer) { create(:customer) }
  let!(:api_access) { create(:api_access, customer:) }
  include_context :customer_v1_cookie_helpers
  let(:auth_token) { build_customer_token(api_access.id, expiration: 1.minute.from_now) }
  let(:type) { 'termination-active-calls' }
  include_context :customer_termination_active_calls_clickhouse_helpers
  let!(:account) { create(:account, contractor: customer) }

  get '/api/rest/customer/v1/termination-active-calls' do
    required_filters = %i[account-id from-time]
    optional_filters = ClickhouseReport::TerminationActiveCalls.filters.reject { |_, v| v.required }.keys
    required_filters.each do |filter_name|
      parameter filter_name, desc: "filter by #{filter_name}", required: true
    end
    optional_filters.each do |filter_name|
      parameter filter_name, desc: "filter by #{filter_name}"
    end

    # required filters
    let(:'account-id') { account.uuid }
    let(:'from-time') { 1.day.ago.iso8601 }
    let(:from_time) { 1.day.ago.iso8601 }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end
end
