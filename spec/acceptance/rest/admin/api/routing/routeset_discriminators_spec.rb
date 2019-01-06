require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Routeset discriminators' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'routeset-discriminators' }

  get '/api/rest/admin/routing/routeset-discriminators' do
    before { create_list(:routeset_discriminator, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/routing/routeset-discriminators/:id' do
    let(:id) { create(:routeset_discriminator).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/routing/routeset-discriminators' do
    parameter :type, 'Resource type (routeset-discriminators)', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:name) { 'name' }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/routing/routeset-discriminators/:id' do
    parameter :type, 'Resource type (routeset-discriminators)', scope: :data, required: true
    parameter :id, 'Routing group ID', scope: :data, required: true

    jsonapi_attributes([:name], [])

    let(:id) { create(:routeset_discriminator).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/routing/routeset-discriminators/:id' do
    let(:id) { create(:routeset_discriminator).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
