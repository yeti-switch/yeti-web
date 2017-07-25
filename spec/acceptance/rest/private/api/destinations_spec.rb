require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Destinations' do
  header 'Accept', 'application/json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

  get '/api/rest/private/destinations' do
    before { create_list(:destination, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/destinations/:id' do
    let(:id) { create(:destination).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/destinations' do
    parameter :enabled,                'Enabled flag',           scope: :destination, required: true
    parameter :prefix,                 'Prefix',                 scope: :destination
    parameter :rateplan_id,            'Rateplan id',            scope: :destination, required: true
    parameter :next_rate,              'Next rate',              scope: :destination, required: true
    parameter :connect_fee,            'Connect fee',            scope: :destination, required: true
    parameter :initial_interval,       'Initial interval',       scope: :destination, required: true
    parameter :next_interval,          'Next interval',          scope: :destination, required: true
    parameter :dp_margin_fixed,        'Dp margin fixed',        scope: :destination, required: true
    parameter :dp_margin_percent,      'Dp margin percent',      scope: :destination, required: true
    parameter :rate_policy_id,         'Rate policy id',         scope: :destination, required: true
    parameter :initial_rate,           'Initial rate',           scope: :destination, required: true
    parameter :reject_calls,           'Reject calls',           scope: :destination
    parameter :use_dp_intervals,       'Use dp intervals',       scope: :destination
    parameter :valid_from,             'Valid from',             scope: :destination
    parameter :valid_till,             'Valid till',             scope: :destination
    parameter :profit_control_mode_id, 'Profit control mode id', scope: :destination
    parameter :external_id,            'External id',            scope: :destination
    parameter :asr_limit,              'Asr limit',              scope: :destination, required: true
    parameter :acd_limit,              'Acd limit',              scope: :destination, required: true
    parameter :short_calls_limit,      'Short calls limit',      scope: :destination, required: true

    let(:rateplan_id) { create(:rateplan).id }
    let(:enabled) { true }
    let(:initial_interval) { 60 }
    let(:next_interval) { 60 }
    let(:initial_rate) { 0 }
    let(:next_rate) { 0 }
    let(:connect_fee) { 0 }
    let(:dp_margin_fixed) { 0 }
    let(:dp_margin_percent) { 0 }
    let(:rate_policy_id) { 1 }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/destinations/:id' do
    parameter :enabled,                'Enabled flag',           scope: :destination, required: true
    parameter :prefix,                 'Prefix',                 scope: :destination
    parameter :rateplan_id,            'Rateplan id',            scope: :destination, required: true
    parameter :next_rate,              'Next rate',              scope: :destination, required: true
    parameter :connect_fee,            'Connect fee',            scope: :destination, required: true
    parameter :initial_interval,       'Initial interval',       scope: :destination, required: true
    parameter :next_interval,          'Next interval',          scope: :destination, required: true
    parameter :dp_margin_fixed,        'Dp margin fixed',        scope: :destination, required: true
    parameter :dp_margin_percent,      'Dp margin percent',      scope: :destination, required: true
    parameter :rate_policy_id,         'Rate policy id',         scope: :destination, required: true
    parameter :initial_rate,           'Initial rate',           scope: :destination, required: true
    parameter :reject_calls,           'Reject calls',           scope: :destination
    parameter :use_dp_intervals,       'Use dp intervals',       scope: :destination
    parameter :valid_from,             'Valid from',             scope: :destination
    parameter :valid_till,             'Valid till',             scope: :destination
    parameter :profit_control_mode_id, 'Profit control mode id', scope: :destination
    parameter :external_id,            'External id',            scope: :destination
    parameter :asr_limit,              'Asr limit',              scope: :destination, required: true
    parameter :acd_limit,              'Acd limit',              scope: :destination, required: true
    parameter :short_calls_limit,      'Short calls limit',      scope: :destination, required: true

    let(:id) { create(:destination).id }
    let(:enabled) { false }

    example_request 'update values' do
      expect(status).to eq(204)
    end
  end

  delete '/api/rest/private/destinations/:id' do
    let(:id) { create(:destination).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
