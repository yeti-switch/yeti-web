# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'CDR Exports', document: :customer_v1 do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:api_access) { create :api_access }
  let(:customer) { api_access.customer }
  include_context :customer_v1_cookie_helpers
  let(:auth_token) { build_customer_token(api_access.id, expiration: 1.minute.from_now) }
  let(:type) { 'cdr-exports' }
  let!(:customer_acc) { FactoryBot.create(:account, contractor: customer).reload }

  post '/api/rest/customer/v1/cdr-exports' do
    parameter :type, 'Resource type (chart-active-calls)', scope: :data, required: true
    required_params = %i[filters]
    required_relations = %i[account]

    jsonapi_attributes(required_params, [])
    jsonapi_relationships(required_relations, [])
    define_parameter 'time-format', scope: %i[data attributes],
                                    desc: "Start/end and time_connect field format: #{CdrExport::ALLOWED_TIME_FORMATS.join(', ')}"
    define_parameter 'time-zone-name', scope: %i[data attributes],
                                       desc: 'Specify time zone name. By default UTC. Example: Europe/Kyiv'

    let(:filters) do
      {
        time_start_gteq: '2019-01-01 00:00:00',
        time_start_lt: '2019-01-02 00:00:00',
        success_eq: true,
        duration_eq: 60,
        duration_gteq: 0,
        duration_lteq: 100,
        src_prefix_routing_eq: '123',
        dst_prefix_routing_eq: '456'
      }
    end
    let(:account) { wrap_relationship(:accounts, customer_acc.uuid) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  get '/api/rest/customer/v1/cdr-exports' do
    jsonapi_filters Api::Rest::Customer::V1::CdrExportResource._allowed_filters

    before { create_list(:cdr_export, 2, customer_account: customer_acc) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/customer/v1/cdr-exports/:id' do
    let(:id) { create(:cdr_export, customer_account: customer_acc).reload.uuid }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
