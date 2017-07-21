require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Contractors' do
  header 'Accept', 'application/json'

  get '/api/rest/private/contractors' do
    before { create_list(:contractor, 2, vendor: true) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/contractors/:id' do
    let(:id) { create(:contractor, vendor: true).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/contractors' do
    parameter :name, 'Contractor name', scope: :contractor, required: true
    parameter :vendor, 'Vendor flag', scope: :contractor
    parameter :customer, 'Customer flag', scope: :contractor
    parameter :enabled, 'Enabled flag', scope: :contractor
    parameter :description, 'Description', scope: :contractor
    parameter :address, 'Address', scope: :contractor
    parameter :phones, 'Phones', scope: :contractor
    parameter :smtp_connection_id, 'SMTP connection id', scope: :contractor

    let(:name) { 'name' }
    let(:vendor) { true }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/contractors/:id' do
    parameter :name, 'Contractor name', scope: :contractor, required: true
    parameter :vendor, 'Vendor flag', scope: :contractor
    parameter :customer, 'Customer flag', scope: :contractor
    parameter :enabled, 'Enabled flag', scope: :contractor
    parameter :description, 'Description', scope: :contractor
    parameter :address, 'Address', scope: :contractor
    parameter :phones, 'Phones', scope: :contractor
    parameter :smtp_connection_id, 'SMTP connection id', scope: :contractor

    let(:id) { create(:contractor, vendor: true).id }
    let(:name) { 'name' }
    let(:customer) { true }

    example_request 'update values' do
      expect(status).to eq(204)
    end
  end

  delete '/api/rest/private/contractors/:id' do
    let(:id) { create(:contractor, vendor: true).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
