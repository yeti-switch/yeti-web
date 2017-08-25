require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Timezones' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'timezones' }

  optional_params = %i(name abbrev utc_offset is_dst)

  get '/api/rest/private/system/timezones' do
    before { create_list(:timezone, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/system/timezones/:id' do
    let(:id) { create(:timezone).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/system/timezones' do
    parameter :type, 'Resource type (timezones)', scope: :data, required: true

    jsonapi_attributes([], optional_params)

    let(:name) { 'name' }
    let(:abbrev) { "UTC" }
    let(:utc_offset) { "00:00:00" }
    let(:is_dst) { false }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/system/timezones/:id' do
    parameter :type, 'Resource type (timezones)', scope: :data, required: true
    parameter :id, 'Timezone ID', scope: :data, required: true

    jsonapi_attributes([], optional_params)

    let(:id) { create(:timezone).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/private/system/timezones/:id' do
    let(:id) { create(:timezone).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
