require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Customer Auths' do
  header 'Accept', 'application/json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

  required_params = [
    :name, :ip, :customer_id, :rateplan_id, :routing_plan_id, :gateway_id, :account_id, :dump_level_id,
    :diversion_policy_id
  ]

  optional_params = [
    :enabled, :src_rewrite_rule, :src_rewrite_result, :dst_rewrite_rule, :dst_rewrite_result,
    :src_prefix, :dst_prefix, :x_yeti_auth, :capacity, :pop_id, :uri_domain,
    :src_name_rewrite_rule, :src_name_rewrite_result, :diversion_rewrite_rule, :diversion_rewrite_result,
    :dst_numberlist_id, :src_numberlist_id, :allow_receive_rate_limit, :send_billing_information,
    :radius_auth_profile_id, :enable_audio_recording, :src_number_radius_rewrite_rule,
    :src_number_radius_rewrite_result, :dst_number_radius_rewrite_rule, :dst_number_radius_rewrite_result,
    :radius_accounting_profile_id, :from_domain, :to_domain, :transport_protocol_id
  ]

  get '/api/rest/private/customers_auths' do
    before { create_list(:customers_auth, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/customers_auths/:id' do
    let(:id) { create(:customers_auth).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/customers_auths' do
    required_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('_', ' '), scope: :customers_auth, required: true
    end

    optional_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('_', ' '), scope: :customers_auth
    end

    let(:name) { 'name' }
    let(:enabled) { true }
    let(:ip) { '0.0.0.0' }
    let(:dump_level_id) { 1 }
    let(:diversion_policy_id) { 1 }
    let(:customer_id) { create(:contractor, customer: true).id }
    let(:rateplan_id) { create(:rateplan).id }
    let(:routing_plan_id) { create(:routing_plan).id }
    let(:gateway_id) { create(:gateway).id }
    let(:account_id) { create(:account).id }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/customers_auths/:id' do
    required_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('_', ' '), scope: :customers_auth, required: true
    end

    optional_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('_', ' '), scope: :customers_auth
    end

    let(:id) { create(:customers_auth).id }
    let(:name) { 'name' }
    let(:capacity) { 2 }

    example_request 'update values' do
      expect(status).to eq(204)
    end
  end

  delete '/api/rest/private/customers_auths/:id' do
    let(:id) { create(:customers_auth).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
