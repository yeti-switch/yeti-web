require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Dialpeer next rates' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'dialpeer-next-rates' }
  let(:dialpeer) { create(:dialpeer) }
  let(:dialpeer_id) { dialpeer.id }

  required_params = [
    :dialpeer_id, :next_rate, :initial_rate, :initial_interval, :next_interval, :connect_fee, :apply_time, :applied
  ]

  optional_params = [:external_id]

  get '/api/rest/private/dialpeer-next-rates' do
    before { create_list(:dialpeer_next_rate, 2, dialpeer: dialpeer) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/dialpeer-next-rates/:id' do
    let(:id) { create(:dialpeer_next_rate, dialpeer: dialpeer).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/dialpeer-next-rates' do
    parameter :type, 'Resource type (dialpeers-next-rates)', scope: :data, required: true

    define_parameters(required_params, optional_params)

    let(:applied) { false }
    let(:'dialpeer-id') { create(:dialpeer).id }
    let(:'apply-time') { 1.hour.from_now }
    let(:'connect-fee') { 0 }
    let(:'initial-interval') { 60 }
    let(:'next-interval') { 60 }
    let(:'initial-rate') { 0.0 }
    let(:'next-rate') { 0.0 }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/dialpeer-next-rates/:id' do
    parameter :type, 'Resource type (dialpeers-next-rates)', scope: :data, required: true
    parameter :id, 'Dialpeer next rate ID', scope: :data, required: true

    define_parameters(required_params, optional_params)

    let(:id) { create(:dialpeer_next_rate, dialpeer: dialpeer).id }
    let(:'initial-rate') { 22 }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/private/dialpeer-next-rates/:id' do
    let(:id) { create(:dialpeer_next_rate).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
