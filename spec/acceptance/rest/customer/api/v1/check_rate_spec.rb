require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'CheckRate', document: :customer_v1 do
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

  before do
    create :destination, rateplan: rateplan, prefix: '444', routing_tag: create(:routing_tag)
  end

  post '/api/rest/customer/v1/check-rate' do
    parameter :type, 'Resource type (check-rates)', scope: :data, required: true

    required_params = %i(rateplan-id number)

    jsonapi_attributes(required_params, [])

    let(:number) { '44444444' }
    let(:'rateplan-id') { rateplan.uuid }

    example_request 'get rates for number' do
      expect(status).to eq(201)
    end
  end

end
