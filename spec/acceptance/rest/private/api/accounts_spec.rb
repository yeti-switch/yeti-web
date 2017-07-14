require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Accounts' do
  header 'Accept', 'application/json'

  required_params = [:name, :min_balance, :max_balance, :contractor_id, :timezone_id]

  optional_params = [
    :origination_capacity, :termination_capacity, :customer_invoice_period_id, :vendor_invoice_period_id,
    :customer_invoice_template_id, :vendor_invoice_template_id, :send_invoices_to
  ]

  get '/api/rest/private/accounts' do
    before { create_list(:account, 2) }

    example_request 'returns listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/accounts/:id' do
    let(:id) { create(:account).id }

    example_request 'returns specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/accounts' do
    required_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('_', ' '), scope: :account, required: true
    end

    optional_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('_', ' '), scope: :account
    end

    let(:name) { 'name' }
    let(:min_balance) { 1 }
    let(:max_balance) { 10 }
    let(:timezone_id) { 1 }
    let(:diversion_policy_id) { 1 }
    let(:contractor_id) { create(:contractor, vendor: true).id }

    example_request 'creates new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/accounts/:id' do
    required_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('_', ' '), scope: :account, required: true
    end

    optional_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('_', ' '), scope: :account
    end

    let(:id) { create(:account).id }
    let(:name) { 'name' }
    let(:max_balance) { 20 }

    example_request 'updates values' do
      expect(status).to eq(204)
    end
  end

  delete '/api/rest/private/accounts/:id' do
    let(:id) { create(:account).id }

    example_request 'deletes resource' do
      expect(status).to eq(204)
    end
  end
end
