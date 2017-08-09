require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Accounts' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'accounts' }

  required_params = %i(name min-balance max-balance contractor-id timezone-id)

  optional_params = %i(
    origination-capacity termination-capacity customer-invoice-period-id vendor-invoice-period-id
    customer-invoice-template-id vendor-invoice-template-id send-invoices-to
  )

  get '/api/rest/private/accounts' do
    before { create_list(:account, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/accounts/:id' do
    let(:id) { create(:account).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/accounts' do
    parameter :type, 'Resource type (accounts)', scope: :data, required: true

    required_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('-', ' '), scope: [:data, :attributes], required: true
    end

    optional_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('-', ' '), scope: [:data, :attributes]
    end

    let(:name) { 'name' }
    let(:'min-balance') { 1 }
    let(:'max-balance') { 10 }
    let(:'timezone-id') { 1 }
    let(:'contractor-id') { create(:contractor, vendor: true).id }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/accounts/:id' do
    parameter :type, 'Resource type (accounts)', scope: :data, required: true
    parameter :id, 'Account ID', scope: :data, required: true

    required_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('-', ' '), scope: [:data, :attributes], required: true
    end

    optional_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('-', ' '), scope: [:data, :attributes]
    end

    let(:id) { create(:account).id }
    let(:name) { 'name' }
    let(:'max-balance') { 20 }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/private/accounts/:id' do
    let(:id) { create(:account).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
