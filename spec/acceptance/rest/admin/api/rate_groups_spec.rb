# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Routing Rate Groups' do
  include_context :acceptance_admin_user

  let(:type) { 'rate-groups' }

  get '/api/rest/admin/rate-groups' do
    jsonapi_filters Api::Rest::Admin::RateGroupResource._allowed_filters

    before { create_list(:rate_group, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/rate-groups/:id' do
    let(:id) { create(:rate_group).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/rate-groups/456329901/relationships/rateplans' do
    parameter :data, 'The rate plans to be associated with the rate group', required: true

    let!(:record) { FactoryBot.create(:rate_group, id: 456_329_901) }
    let!(:rateplan) { create(:rateplan) }
    let(:data) { [{ type: 'rateplans', id: rateplan.id.to_s }] }

    example_request 'associate rateplans with rate group' do
      expect(status).to eq(204)
      expect(record.reload).to have_attributes(rateplan_ids: [rateplan.id])
    end
  end
end
