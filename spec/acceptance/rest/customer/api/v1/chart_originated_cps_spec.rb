# frozen_string_literal: true

require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'OriginatedCPS', document: :customer_v1 do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:api_access) { create :api_access }
  let(:customer) { api_access.customer }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: api_access.id }).token }
  let(:type) { 'chart-originated-cps' }

  let!(:customer_acc) { create(:account, contractor: customer).reload }

  before do
    create_list :cdr, 12,
                customer_acc_id: customer_acc.id,
                is_last_cdr: true,
                time_start: '2019-01-01 23:59:59'
  end

  post '/api/rest/customer/v1/chart-originated-cps' do
    parameter :type, 'Resource type (chart-originated-cps)', scope: :data, required: true

    required_params = %i[from-time to-time]
    required_relations = %i[account]

    jsonapi_attributes(required_params, [])
    jsonapi_relationships(required_relations, [])

    let(:'from-time') { '2019-01-01 00:00:00' }
    let(:'to-time') { '2019-01-02 00:00:00' }
    let(:account) { wrap_relationship(:accounts, customer_acc.uuid) }

    example_request 'get originated CPS chart for account during time period' do
      expect(status).to eq(201)
    end
  end
end
