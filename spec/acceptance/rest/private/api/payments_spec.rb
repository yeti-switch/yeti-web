require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Payments' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'payments' }

  get '/api/rest/private/payments' do
    before { create_list(:payment, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/payments/:id' do
    let(:id) { create(:payment).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/payments' do
    parameter :type, 'Resource type (payments)', scope: :data, required: true

    jsonapi_attributes([:amount], [:notes])
    jsonapi_relationships([:account], [])

    let(:amount) { 10 }
    let(:account) { wrap_relationship(:accounts, create(:account).id) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end
end
