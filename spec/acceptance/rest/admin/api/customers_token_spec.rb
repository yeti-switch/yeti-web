# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Customer Token' do
  include_context :acceptance_admin_user
  let(:type) { 'customer-tokens' }

  post '/api/rest/admin/customer-tokens' do
    parameter :type, 'Resource type (customer-tokens)', scope: :data, required: true

    jsonapi_attributes(
      [],
      %i[allow-listen-recording allowed-ips customer-portal-access-profile-id]
    )
    jsonapi_relationships(
      %i[customer],
      %i[accounts allow-outgoing-numberlists provision-gateway]
    )

    let!(:contractor) { create(:contractor, customer: true) }

    let(:'allow-listen-recording') { true }
    let(:'allowed-ips') { ['10.20.30.40', '11.12.13.14'] }
    let(:'customer-portal-access-profile-id') { create(:customer_portal_access_profile).id }
    let(:customer) { wrap_relationship(:contractors, contractor.id) }
    let(:'allow-outgoing-numberlists') do
      wrap_has_many_relationship(
        :numberlists,
        create_list(:numberlist, 2).map(&:id)
      )
    end
    let(:'provision-gateway') { wrap_relationship(:gateways, create(:gateway, contractor: contractor).id) }
    let(:accounts) do
      wrap_has_many_relationship(
        :accounts,
        create_list(:account, 2, contractor: contractor).map(&:id)
      )
    end

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end
end
