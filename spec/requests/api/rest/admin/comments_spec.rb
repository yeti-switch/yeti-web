# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::CommentsController, type: :request do
  include_context :json_api_admin_helpers, type: :comments

  let!(:dialpeer) { FactoryBot.create(:dialpeer) }

  def create_comment(resource, body: 'some comment', namespace: 'root')
    ActiveAdmin::Comment.create!(resource:, body:, namespace:, author: admin_user)
  end

  shared_examples :forbidden_by_comment_policy do |action|
    context "when role policy disallows #{action}" do
      before do
        policy_roles = (Rails.configuration.policy_roles || {}).deep_merge(
          user: { 'ActiveAdmin/Comment': { action => false } }
        )
        allow(Rails.configuration).to receive(:policy_roles).and_return(policy_roles)
      end

      include_examples :responds_with_status, 403, without_body: true
    end
  end

  shared_context :comment_policy_allows do |action|
    before do
      policy_roles = (Rails.configuration.policy_roles || {}).deep_merge(
        user: { 'ActiveAdmin/Comment': { action => true } }
      )
      allow(Rails.configuration).to receive(:policy_roles).and_return(policy_roles)
    end
  end

  describe 'GET /api/rest/admin/comments' do
    subject do
      get json_api_request_path, params: request_params, headers: json_api_request_headers
    end

    include_context :comment_policy_allows, :read

    let(:request_params) { nil }
    let!(:comments) do
      [
        create_comment(dialpeer),
        create_comment(FactoryBot.create(:account))
      ]
    end

    before { create_comment(dialpeer, namespace: 'other') }

    include_examples :jsonapi_responds_with_pagination_links
    include_examples :returns_json_api_collection do
      let(:json_api_collection_ids) { comments.map { |r| r.id.to_s } }
    end

    context 'with filter by resource' do
      let(:request_params) do
        { filter: { resource_type_eq: 'Dialpeer', resource_id_eq: dialpeer.id.to_s } }
      end

      it 'returns only comments on that resource' do
        subject
        expect(response.status).to eq(200)
        expect(response_json[:data].map { |r| r[:id] }).to eq [comments.first.id.to_s]
      end
    end

    it_behaves_like :json_api_admin_check_authorization
    include_examples :forbidden_by_comment_policy, :read
  end

  describe 'GET /api/rest/admin/comments/{id}' do
    subject do
      get json_api_request_path, params: nil, headers: json_api_request_headers
    end

    include_context :comment_policy_allows, :read

    let(:json_api_request_path) { "#{super()}/#{comment.id}" }
    let!(:comment) { create_comment(dialpeer) }

    include_examples :returns_json_api_record do
      let(:json_api_record_id) { comment.id.to_s }
      let(:json_api_record_attributes) do
        {
          body: comment.body,
          'resource-type': 'Dialpeer',
          'resource-id': dialpeer.id.to_s,
          'author-id': admin_user.id,
          'created-at': comment.created_at.iso8601(3)
        }
      end
    end

    it_behaves_like :json_api_admin_check_authorization
    include_examples :forbidden_by_comment_policy, :read
  end

  describe 'POST /api/rest/admin/comments' do
    subject do
      post json_api_request_path, params: json_api_request_body.to_json, headers: json_api_request_headers
    end

    include_context :comment_policy_allows, :change

    let(:json_api_request_body) do
      { data: { type: json_api_resource_type, attributes: json_api_request_attributes } }
    end
    let(:json_api_request_attributes) do
      {
        body: 'Rate lowered after vendor renegotiation',
        'resource-type': 'Dialpeer',
        'resource-id': dialpeer.id.to_s
      }
    end
    let(:last_comment) { ActiveAdmin::Comment.last! }

    include_examples :returns_json_api_record, status: 201 do
      let(:json_api_record_id) { last_comment.id.to_s }
      let(:json_api_record_attributes) do
        {
          body: 'Rate lowered after vendor renegotiation',
          'resource-type': 'Dialpeer',
          'resource-id': dialpeer.id.to_s,
          'author-id': admin_user.id,
          'created-at': last_comment.created_at.iso8601(3)
        }
      end
    end

    include_examples :changes_records_qty_of, ActiveAdmin::Comment, by: 1

    it 'attaches the comment to the resource as the current admin user' do
      subject
      expect(last_comment).to have_attributes(
        resource: dialpeer,
        author: admin_user,
        namespace: 'root'
      )
    end

    context 'with resource-type that is not commentable' do
      let(:json_api_request_attributes) { super().merge('resource-type': 'Kernel') }

      include_examples :responds_with_status, 422
      include_examples :changes_records_qty_of, ActiveAdmin::Comment, by: 0
    end

    context 'with resource-id that does not exist' do
      let(:json_api_request_attributes) { super().merge('resource-id': (dialpeer.id + 1_000).to_s) }

      include_examples :responds_with_status, 422
      include_examples :changes_records_qty_of, ActiveAdmin::Comment, by: 0
    end

    context 'without body' do
      let(:json_api_request_attributes) { super().except(:body) }

      include_examples :responds_with_status, 422
      include_examples :changes_records_qty_of, ActiveAdmin::Comment, by: 0
    end

    it_behaves_like :json_api_admin_check_authorization, status: 201
    include_examples :forbidden_by_comment_policy, :change
  end
end
