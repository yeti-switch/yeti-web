# frozen_string_literal: true

RSpec.describe Api::Rest::Admin::CodecGroupsController, type: :controller do
  let(:user) { create :admin_user }
  let(:auth_token) { ::Knock::AuthToken.new(payload: { sub: user.id }).token }

  before do
    request.accept = 'application/vnd.api+json'
    request.headers['Content-Type'] = 'application/vnd.api+json'
    request.headers['Authorization'] = auth_token
  end

  describe 'GET index with ransack filters' do
    subject do
      get :index, params: json_api_request_query
    end
    let(:factory) { :codec_group }
    let(:json_api_request_query) { nil }

    it_behaves_like :jsonapi_filters_by_string_field, :name
  end
end
