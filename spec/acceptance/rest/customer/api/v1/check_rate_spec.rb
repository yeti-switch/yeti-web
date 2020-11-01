# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'CheckRate', document: :customer_v1 do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:api_access) { create :api_access }
  let(:customer) { api_access.customer }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: api_access.id }).token }
  let(:type) { 'check-rates' }

  let(:customers_auth) do
    create(:customers_auth, customer_id: customer.id)
  end

  let!(:rateplan) { customers_auth.rateplan.reload }
  let!(:rate_group) { create(:rate_group, rateplans:[rateplan]) }


  before do
    create :destination, rate_group: rate_group, prefix: '444', routing_tag_ids: [create(:routing_tag, :ua).id, create(:routing_tag, :us).id]
  end

  post '/api/rest/customer/v1/check-rate' do
    parameter :type, 'Resource type (check-rates)', scope: :data, required: true

    required_params = %i[rateplan-id number]

    jsonapi_attributes(required_params, [])

    let(:number) { '44444444' }
    let(:'rateplan-id') { rateplan.uuid }

    example_request 'get rates for number' do
      expect(status).to eq(201)
    end
  end
end
