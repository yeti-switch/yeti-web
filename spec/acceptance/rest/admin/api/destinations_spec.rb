# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Destinations' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'destinations' }

  required_params = %i[
    enabled next-rate connect-fee initial-interval next-interval dp-margin-fixed dp-margin-percent
    initial-rate asr-limit acd-limit short-calls-limit
  ]
  optional_params = %i[
    prefix reject-calls use-dp-intervals valid-from valid-till external-id routing-tag-ids
    dst_number-min-length dst-number-max-length reverse-billing profit-control-mode-id rate-policy-id
  ]

  required_relationships = %i[rate-group]
  optional_relationships = %i[routing-tag-modes]

  get '/api/rest/admin/destinations' do
    jsonapi_filters Api::Rest::Admin::DestinationResource._allowed_filters

    before { create_list(:destination, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/destinations/:id' do
    let(:id) { create(:destination).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/destinations' do
    parameter :type, 'Resource type (destinations)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:'rate-group') { wrap_relationship(:'rate-groups', create(:rate_group).id) }
    let(:enabled) { true }
    let(:'initial-interval') { 60 }
    let(:'next-interval') { 60 }
    let(:'initial-rate') { 0 }
    let(:'next-rate') { 0 }
    let(:'connect-fee') { 0 }
    let(:'dp-margin-fixed') { 0 }
    let(:'dp-margin-percent') { 0 }
    let(:'rate-policy') { wrap_relationship(:'destination-rate-policies', 1) }
    let(:'dst-number-min-length') { 0 }
    let(:'dst-number-max-length') { 100 }
    let(:'reverse-billing') { true }
    let(:'rate-policy-id') { Routing::DestinationRatePolicy::POLICY_FIXED }
    let(:'profit-control-mode-id') { Routing::RateProfitControlMode::MODE_PER_CALL }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/destinations/:id' do
    parameter :type, 'Resource type (destinations)', scope: :data, required: true
    parameter :id, 'Destination ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)

    let(:id) { create(:destination).id }
    let(:enabled) { false }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/destinations/:id' do
    let(:id) { create(:destination).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
