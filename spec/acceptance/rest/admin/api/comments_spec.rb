# frozen_string_literal: true

require 'rspec_api_documentation/dsl'

RSpec.resource 'Comments' do
  include_context :acceptance_admin_user
  let(:type) { 'comments' }

  let(:dialpeer) { create(:dialpeer) }

  def create_comment
    ActiveAdmin::Comment.create!(resource: dialpeer, body: 'some comment', namespace: 'root', author: admin_user)
  end

  get '/api/rest/admin/comments' do
    jsonapi_filters Api::Rest::Admin::CommentResource._allowed_filters

    before { 2.times { create_comment } }

    example_request 'get listing' do
      expect(status).to eq(200)
    end
  end

  get '/api/rest/admin/comments/:id' do
    let(:id) { create_comment.id }

    example_request 'get specific entry' do
      expect(status).to eq(200)
    end
  end

  post '/api/rest/admin/comments' do
    parameter :type, 'Resource type (comments)', scope: :data, required: true

    jsonapi_attributes(%i[body resource_type resource_id], [])

    let(:body) { 'Rate lowered after vendor renegotiation' }
    let(:'resource-type') { 'Dialpeer' }
    let(:'resource-id') { dialpeer.id.to_s }

    example_request 'create new entry' do
      expect(status).to eq(201)
    end
  end
end
