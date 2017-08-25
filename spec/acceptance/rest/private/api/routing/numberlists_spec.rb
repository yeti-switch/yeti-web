require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Numberlist' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'routing/numberlists' }

  required_params = %i(name)
  optional_params = %i(
    default-src-rewrite-rule default-src-rewrite-result default-dst-rewrite-rule default-dst-rewrite-result
  )
  required_relationships = %i(mode default-action)

  get '/api/rest/private/routing/numberlists' do
    before { create_list(:numberlist, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/private/routing/numberlists/:id' do
    let(:id) { create(:numberlist).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/private/routing/numberlists' do
    parameter :type, 'Resource type (routing/numberlists)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, [])

    let(:name) { 'name' }
    let(:mode) { wrap_relationship(:'routing/numberlist-mode', 1) }
    let(:'default-action') { wrap_relationship(:'routing/numberlist-action', 1) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/private/routing/numberlists/:id' do
    parameter :type, 'Resource type (routing/numberlists)', scope: :data, required: true
    parameter :id, 'Numberlist ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, [])

    let(:id) { create(:numberlist).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/private/routing/numberlists/:id' do
    let(:id) { create(:numberlist).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
