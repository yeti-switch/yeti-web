require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Payments' do
  header 'Accept', 'application/json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

  required_params = [:amount, :account_id]

  optional_params = [:notes]

  get '/api/rest/private/payments' do
    before { create_list(:payment, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/payments/:id' do
    let(:id) { create(:payment).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/payments' do
    required_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('_', ' '), scope: :payment, required: true
    end

    optional_params.each do |param|
      parameter param, param.to_s.capitalize.gsub('_', ' '), scope: :payment
    end

    let(:amount) { 10 }
    let(:account_id) { create(:account).id }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end
end
