# frozen_string_literal: true

require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Rateplans' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'rateplans' }

  let(:profit_control_mode) { Routing::RateProfitControlMode.last }

  get '/api/rest/admin/rateplans' do
    jsonapi_filters Api::Rest::Admin::RateplanResource._allowed_filters

    before { create_list(:rateplan, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/rateplans/:id' do
    let(:id) { create(:rateplan).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/rateplans' do
    parameter :type, 'Resource type (rateplans)', scope: :data, required: true

    jsonapi_attributes([:name], [])
    jsonapi_relationships([:'profit-control-mode'], [])

    let(:name) { 'name' }
    let(:'profit-control-mode') { wrap_relationship(:rate_profit_control_modes, profit_control_mode.id) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/rateplans/:id' do
    parameter :type, 'Resource type (rateplans)', scope: :data, required: true
    parameter :id, 'Rateplan ID', scope: :data, required: true

    jsonapi_attributes([:name], [])
    jsonapi_relationships([:'profit-control-mode'], [])

    let(:id) { create(:rateplan).id }
    let(:name) { 'name' }
    let(:'profit-control-mode') { wrap_relationship(:rate_profit_control_modes, profit_control_mode.id) }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/rateplans/:id' do
    let(:id) { create(:rateplan).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
