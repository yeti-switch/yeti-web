require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Rateplans' do
  header 'Accept', 'application/json'

  get '/api/rest/private/rateplans' do
    before { create_list(:rateplan, 2) }

    example_request 'returns listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/rateplans/:id' do
    let(:id) { create(:rateplan).id }

    example_request 'returns specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/rateplans' do
    parameter :name, 'Rateplan name', scope: :rateplan, required: true
    parameter :profit_control_mode_id, 'Rate profit control mode id', scope: :rateplan, required: true

    let(:name) { 'name' }
    let(:profit_control_mode_id) { create(:rate_profit_control_mode).id }

    example_request 'creates new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/rateplans/:id' do
    parameter :name, 'Rateplan name', scope: :rateplan, required: true
    parameter :profit_control_mode_id, 'Rate profit control mode id', scope: :rateplan, required: true

    let(:id) { create(:rateplan).id }
    let(:name) { 'name' }
    let(:profit_control_mode_id) { create(:rate_profit_control_mode).id }

    example_request 'updates values' do
      expect(status).to eq(204)
    end
  end

  delete '/api/rest/private/rateplans/:id' do
    let(:id) { create(:rateplan).id }

    example_request 'deletes resource' do
      expect(status).to eq(204)
    end
  end
end
