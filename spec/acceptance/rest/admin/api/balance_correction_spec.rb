# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Balances correction' do
  explanation 'The balance correction resource allows you to modify account balance by applying **correction**. Correction may be negative or positive'

  include_context :acceptance_admin_user
  let(:type) { 'balance-correction' }

  required_params = %i[correction]
  optional_params = %i[]

  required_relationships = %i[]
  optional_relationships = %i[]

  let!(:debug) { System::ApiLogConfig.create(controller: 'Api::Rest::Admin::BalanceCorrectionController') }

  put '/api/rest/admin/accounts/:id/balance-correction' do
    parameter :type, 'Resource type (balance-correction)', scope: :data, required: true
    parameter :id, 'Account ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:id) { create(:account, balance: 100).id }
    let(:correction) { '21' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end
end
