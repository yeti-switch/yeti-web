# frozen_string_literal: true

require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Rateplans', document: :customer_v1 do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:api_access) { create :api_access }
  let(:customer) { api_access.customer }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: api_access.id }).token }
  let(:type) { 'rateplans' }

  required_params = %i[name]

  let(:customers_auth) do
    create(:customers_auth, customer_id: customer.id)
  end

  let!(:rateplan) { customers_auth.rateplan.reload }

  get '/api/rest/customer/v1/rateplans' do
    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/customer/v1/rateplans/:id' do
    let(:id) { rateplan.reload.uuid }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end
end
