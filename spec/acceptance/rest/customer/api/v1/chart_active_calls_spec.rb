# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'ChartActiveCalls', document: :customer_v1 do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:api_access) { create :api_access }
  let(:customer) { api_access.customer }
  include_context :customer_v1_cookie_helpers
  let(:auth_token) { build_customer_token(api_access.id, expiration: 1.minute.from_now) }
  let(:type) { 'chart-active-calls' }

  let!(:customer_acc) { create(:account, contractor: customer).reload }

  before do
    create :active_call_account,
           account: customer_acc,
           originated_count: 10,
           terminated_count: 15,
           created_at: '2019-01-01 00:00:01'
  end

  post '/api/rest/customer/v1/chart-active-calls' do
    parameter :type, 'Resource type (chart-active-calls)', scope: :data, required: true

    required_params = %i[from-time to-time]
    required_relations = %i[account]

    jsonapi_attributes(required_params, [])
    jsonapi_relationships(required_relations, [])

    let(:'from-time') { '2019-01-01 00:00:00' }
    let(:'to-time') { '2019-01-02 00:00:00' }
    let(:account) { wrap_relationship(:accounts, customer_acc.uuid) }

    example_request 'get active calls chart for account during time period' do
      expect(status).to eq(201)
    end
  end
end
