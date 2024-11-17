# frozen_string_literal: true

RSpec.shared_context :json_api_admin_helpers do |type: nil|
  let(:json_api_resource_type) { type.to_s }
  let(:json_api_auth_token) { Authentication::AdminAuth.build_auth_data(admin_user).token }
  let(:json_api_request_path_prefix) { '/api/rest/admin' }
  let(:json_api_request_path) { "#{json_api_request_path_prefix}/#{json_api_resource_type}" }
  let(:json_api_request_headers) do
    {
      'Accept' => JSONAPI::MEDIA_TYPE,
      'Content-Type' => JSONAPI::MEDIA_TYPE,
      'Authorization' => json_api_auth_token
    }
  end

  let!(:admin_user) { FactoryBot.create(:admin_user) }
end
