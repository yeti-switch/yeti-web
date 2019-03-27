# frozen_string_literal: true

RSpec.shared_context :json_api_customer_v1_helpers do |type: nil|
  let(:json_api_resource_type) { type.to_s.dasherize }
  let(:json_api_auth_token) { ::Knock::AuthToken.new(payload: { sub: api_access.id }).token }
  let(:json_api_request_path_prefix) { '/api/rest/customer/v1' }
  let(:json_api_request_path) { "#{json_api_request_path_prefix}/#{json_api_resource_type}" }
  let(:json_api_request_headers) do
    {
      'Accept' => JSONAPI::MEDIA_TYPE,
      'Content-Type' => JSONAPI::MEDIA_TYPE,
      'Authorization' => json_api_auth_token
    }
  end

  let!(:api_access) { create :api_access, api_access_attrs }
  let(:api_access_attrs) { {} }
  let(:customer) { api_access.customer }
end
