require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Dialpeers' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'dialpeers' }

  required_params = [
    :enabled, :routing_group_id, :next_rate, :connect_fee, :vendor_id, :account_id, :initial_rate, :initial_interval,
    :next_interval, :valid_from, :valid_till
  ]

  optional_params = [
    :prefix, :src_rewrite_rule, :dst_rewrite_rule, :acd_limit, :asr_limit, :gateway_id, :src_rewrite_result,
    :dst_rewrite_result, :locked, :priority, :exclusive_route, :capacity, :lcr_rate_multiplier, :gateway_group_id,
    :force_hit_rate, :network_prefix_id, :created_at, :short_calls_limit, :external_id
  ]

    get '/api/rest/private/dialpeers' do
    before { create_list(:dialpeer, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/dialpeers/:id' do
    let(:id) { create(:dialpeer).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/dialpeers' do
    parameter :type, 'Resource type (dialpeers)', scope: :data, required: true

    define_parameters(required_params, optional_params)

    let(:vendor) { create :contractor, vendor: true }
    let(:account) { create :account, contractor: vendor }
    let(:gateway_group) { create :gateway_group, vendor: vendor }
    let(:routing_group) { create :routing_group }

    let(:enabled) { true }
    let(:'account-id') { account.id }
    let(:'vendor-id') { vendor.id }
    let(:'gateway-group-id') { gateway_group.id }
    let(:'routing-group-id') { routing_group.id }
    let(:'valid-from') { DateTime.now }
    let(:'valid-till') { 1.year.from_now }
    let(:'initial-interval') { 60 }
    let(:'next-interval') { 60 }
    let(:'initial-rate') { 0.0 }
    let(:'next-rate') { 0.0 }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/dialpeers/:id' do
    parameter :type, 'Resource type (dialpeers)', scope: :data, required: true
    parameter :id, 'Dialpeer ID', scope: :data, required: true

    define_parameters(required_params, optional_params)

    let(:id) { create(:dialpeer).id }
    let(:capacity) { 20 }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/private/dialpeers/:id' do
    let(:id) { create(:dialpeer).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
