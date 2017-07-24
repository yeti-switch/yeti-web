require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Dialpeers' do
  header 'Accept', 'application/json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

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
    parameter :enabled,             'Enabled flag',        scope: :dialpeer, required: true
    parameter :prefix,              'Prefix',              scope: :dialpeer
    parameter :src_rewrite_rule,    'Src rewrite rule',    scope: :dialpeer
    parameter :dst_rewrite_rule,    'Dst rewrite rule',    scope: :dialpeer
    parameter :acd_limit,           'Acd limit',           scope: :dialpeer
    parameter :asr_limit,           'Asr limit',           scope: :dialpeer
    parameter :gateway_id,          'Gateway id',          scope: :dialpeer
    parameter :routing_group_id,    'Routing group id',    scope: :dialpeer, required: true
    parameter :next_rate,           'Next rate',           scope: :dialpeer, required: true
    parameter :connect_fee,         'Connect fee',         scope: :dialpeer, required: true
    parameter :vendor_id,           'Vendor id',           scope: :dialpeer, required: true
    parameter :account_id,          'Account id',          scope: :dialpeer, required: true
    parameter :src_rewrite_result,  'Src rewrite result',  scope: :dialpeer
    parameter :dst_rewrite_result,  'Dst rewrite result',  scope: :dialpeer
    parameter :locked,              'Locked',              scope: :dialpeer
    parameter :priority,            'Priority',            scope: :dialpeer
    parameter :exclusive_route,     'Exclusive route',     scope: :dialpeer
    parameter :capacity,            'Capacity',            scope: :dialpeer
    parameter :lcr_rate_multiplier, 'Lcr rate multiplier', scope: :dialpeer
    parameter :initial_rate,        'Initial rate',        scope: :dialpeer, required: true
    parameter :initial_interval,    'Initial interval',    scope: :dialpeer, required: true
    parameter :next_interval,       'Next interval',       scope: :dialpeer, required: true
    parameter :valid_from,          'Valid from',          scope: :dialpeer, required: true
    parameter :valid_till,          'Valid till',          scope: :dialpeer, required: true
    parameter :gateway_group_id,    'Gateway group id',    scope: :dialpeer
    parameter :test,                'Test',                scope: :dialpeer
    parameter :force_hit_rate,      'Force hit rate',      scope: :dialpeer
    parameter :network_prefix_id,   'Network prefix id',   scope: :dialpeer
    parameter :created_at,          'Created at',          scope: :dialpeer
    parameter :short_calls_limit,   'Short calls limit',   scope: :dialpeer
    parameter :external_id,         'External id',         scope: :dialpeer

    let(:vendor) { create :contractor, vendor: true }
    let(:account) { create :account, contractor: vendor }
    let(:gateway_group) { create :gateway_group, vendor: vendor }
    let(:routing_group) { create :routing_group }

    let(:enabled) { true }
    let(:account_id) {account.id}
    let(:vendor_id) { vendor.id }
    let(:gateway_group_id) { gateway_group.id }
    let(:routing_group_id) { routing_group.id }
    let(:valid_from) { DateTime.now }
    let(:valid_till) { 1.year.from_now }
    let(:initial_interval) { 60 }
    let(:next_interval) { 60 }
    let(:initial_rate) { 0.0 }
    let(:next_rate) { 0.0 }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/dialpeers/:id' do
    parameter :enabled,             'Enabled flag',        scope: :dialpeer, required: true
    parameter :prefix,              'Prefix',              scope: :dialpeer
    parameter :src_rewrite_rule,    'Src rewrite rule',    scope: :dialpeer
    parameter :dst_rewrite_rule,    'Dst rewrite rule',    scope: :dialpeer
    parameter :acd_limit,           'Acd limit',           scope: :dialpeer
    parameter :asr_limit,           'Asr limit',           scope: :dialpeer
    parameter :gateway_id,          'Gateway id',          scope: :dialpeer
    parameter :routing_group_id,    'Routing group id',    scope: :dialpeer, required: true
    parameter :next_rate,           'Next rate',           scope: :dialpeer, required: true
    parameter :connect_fee,         'Connect fee',         scope: :dialpeer, required: true
    parameter :vendor_id,           'Vendor id',           scope: :dialpeer, required: true
    parameter :account_id,          'Account id',          scope: :dialpeer, required: true
    parameter :src_rewrite_result,  'Src rewrite result',  scope: :dialpeer
    parameter :dst_rewrite_result,  'Dst rewrite result',  scope: :dialpeer
    parameter :locked,              'Locked',              scope: :dialpeer
    parameter :priority,            'Priority',            scope: :dialpeer
    parameter :exclusive_route,     'Exclusive route',     scope: :dialpeer
    parameter :capacity,            'Capacity',            scope: :dialpeer
    parameter :lcr_rate_multiplier, 'Lcr rate multiplier', scope: :dialpeer
    parameter :initial_rate,        'Initial rate',        scope: :dialpeer, required: true
    parameter :initial_interval,    'Initial interval',    scope: :dialpeer, required: true
    parameter :next_interval,       'Next interval',       scope: :dialpeer, required: true
    parameter :valid_from,          'Valid from',          scope: :dialpeer, required: true
    parameter :valid_till,          'Valid till',          scope: :dialpeer, required: true
    parameter :gateway_group_id,    'Gateway group id',    scope: :dialpeer
    parameter :force_hit_rate,      'Force hit rate',      scope: :dialpeer
    parameter :network_prefix_id,   'Network prefix id',   scope: :dialpeer
    parameter :created_at,          'Created at',          scope: :dialpeer
    parameter :short_calls_limit,   'Short calls limit',   scope: :dialpeer
    parameter :external_id,         'External id',         scope: :dialpeer

    let(:id) { create(:dialpeer).id }
    let(:capacity) { 20 }

    example_request 'update values' do
      expect(status).to eq(204)
    end
  end

  delete '/api/rest/private/dialpeers/:id' do
    let(:id) { create(:dialpeer).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
