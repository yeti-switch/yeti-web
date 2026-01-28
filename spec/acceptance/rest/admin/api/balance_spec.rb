# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Balances' do
  explanation 'The balance resource allows you to set account balance. This resource using Account **external_id** as primary key.'

  include_context :acceptance_admin_user
  let(:type) { 'balances' }

  required_params = %i[balance]
  optional_params = %i[]

  required_relationships = %i[]
  optional_relationships = %i[]

  put '/api/rest/admin/accounts/:id/balance' do
    parameter :type, 'Resource type (balances)', scope: :data, required: true
    parameter :id, 'Account External ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:id) { create(:account, balance: 100).external_id }
    let(:balance) { '21' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end
end
