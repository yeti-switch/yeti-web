# frozen_string_literal: true

RSpec.shared_context :json_api_admin_helpers do |type: nil, prefix: nil|
  prefix ||= '/api/rest/admin'
  let(:json_api_resource_type) { type.to_s }
  let(:json_api_auth_token) { ::Knock::AuthToken.new(payload: { sub: admin_user.id }).token }
  let(:json_api_request_path_prefix) { prefix }
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
