require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Gateway groups' do
  header 'Accept', 'application/json'

  get '/api/rest/private/gateway_groups' do
    before { create_list(:gateway_group, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/gateway_groups/:id' do
    let(:id) { create(:gateway_group).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/gateway_groups' do
    parameter :name, 'Gateway group name', scope: :gateway_group, required: true
    parameter :vendor_id, 'Vendor id', scope: :gateway_group, required: true

    let(:name) { 'name' }
    let(:vendor_id) { create(:contractor, vendor: true).id }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/gateway_groups/:id' do
    parameter :name, 'Gateway group name', scope: :gateway_group, required: true
    parameter :vendor_id, 'Vendor id', scope: :gateway_group, required: true

    let(:id) { create(:gateway_group).id }
    let(:name) { 'name' }
    let(:vendor_id) { create(:contractor, vendor: true).id }

    example_request 'update values' do
      expect(status).to eq(204)
    end
  end

  delete '/api/rest/private/gateway_groups/:id' do
    let(:id) { create(:gateway_group).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
