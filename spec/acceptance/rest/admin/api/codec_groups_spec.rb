require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource 'Codec groups' do
  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/vnd.api+json'
  header 'Authorization', :auth_token

  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }
  let(:type) { 'codec-groups' }

  get '/api/rest/admin/codec-groups' do
    before { create_list(:codec_group, 2) }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/codec-groups/:id' do
    let(:id) { create(:codec_group).id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/codec-groups' do
    parameter :type, 'Resource type (codec-groups)', scope: :data, required: true

    jsonapi_attributes([:name], [])
    jsonapi_relationships([:codecs], [])

    let(:group) { create :codec_group }
    let(:codec) { create :codec_group_codec, codec_group: group }

    let(:name) { 'name' }
    let(:codecs) { wrap_has_many_relationship(:'codec-group-codecs', [codec.id]) }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end

  put '/api/rest/admin/codec-groups/:id' do
    parameter :type, 'Resource type (codec-groups)', scope: :data, required: true
    parameter :id, 'Codec group ID', scope: :data, required: true

    jsonapi_attributes([:name], [])


    let(:id) { create(:codec_group).id }
    let(:name) { 'name' }

    example_request 'update values' do
      expect(status).to eq(200)
    end
  end

  delete '/api/rest/admin/codec-groups/:id' do
    let(:id) { create(:codec_group).id }

    example_request 'delete entry' do
      expect(status).to eq(204)
    end
  end
end
