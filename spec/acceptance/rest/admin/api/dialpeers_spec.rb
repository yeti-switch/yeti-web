require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Dialpeers' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'dialpeers' }

  required_params = %i(
    enabled next-rate connect-fee initial-rate initial-interval next-interval valid-from valid-till
  )

  optional_params = %i(
    prefix src-rewrite-rule dst-rewrite-rule acd-limit asr-limit src-rewrite-result
    dst-rewrite-result locked priority exclusive-route capacity lcr-rate-multiplier
    force-hit-rate network-prefix-id created-at short-calls-limit external-id
  )

  required_relationships = %i(routing-group vendor account)
  optional_relationships = %i(gateway gateway-group)

  get '/api/rest/admin/dialpeers' do
    before { create_list(:dialpeer, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/dialpeers/:id' do
    let(:id) { create(:dialpeer).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/dialpeers' do
    parameter :type, 'Resource type (dialpeers)', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)
    jsonapi_relationships(required_relationships, optional_relationships)

    let(:new_vendor) { create :contractor, vendor: true }

    let(:enabled) { true }
    let(:vendor) { wrap_relationship(:contractors, new_vendor.id) }
    let(:account) { wrap_relationship(:accounts, create(:account, contractor: new_vendor).id) }
    let(:'gateway-group') { wrap_relationship(:'gateway-groups', create(:gateway_group, vendor: new_vendor).id) }
    let(:'routing-group') { wrap_relationship(:'routing-groups', create(:routing_group).id) }
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

  put '/api/rest/admin/dialpeers/:id' do
    parameter :type, 'Resource type (dialpeers)', scope: :data, required: true
    parameter :id, 'Dialpeer ID', scope: :data, required: true

    jsonapi_attributes(required_params, optional_params)

    let(:id) { create(:dialpeer).id }
    let(:capacity) { 20 }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/dialpeers/:id' do
    let(:id) { create(:dialpeer).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
