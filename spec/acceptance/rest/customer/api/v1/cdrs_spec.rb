require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Cdrs', document: :customer_v1 do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:api_access) { create :api_access }
  let(:customer) { api_access.customer }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: api_access.id }).token }
  let(:type) { 'cdrs' }

  let(:customers_auth) do
    create(:customers_auth, customer_id: customer.id)
  end

  before do
    # link customer and account
    customers_auth.account.update(contractor_id: customer.id)
  end

  get '/api/rest/customer/v1/cdrs' do
    before { create_list(:cdr, 2, customer_acc: customers_auth.account) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/customer/v1/cdrs/:id' do
    let(:id) { create(:cdr, customer_acc: customers_auth.account).uuid }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

end
