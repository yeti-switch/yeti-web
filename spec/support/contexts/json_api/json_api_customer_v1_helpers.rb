# frozen_string_literal: true

RSpec.shared_context :json_api_customer_v1_helpers do |type: nil|
  include_context :customer_v1_cookie_helpers

  let(:json_api_resource_type) { type.to_s.dasherize }
  let(:json_api_auth_token) { build_customer_token(api_access.id, expiration: 1.minute.from_now) }
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

  let(:json_api_request_body) { { data: json_api_request_data } }
  let(:json_api_request_data) do
    data = { type: json_api_resource_type, attributes: json_api_request_attributes }
    data[:relationships] = json_api_relationships unless json_api_relationships.nil?
    data
  end
  let(:json_api_relationships) { nil }
  let(:json_api_request_attributes) do
    raise 'override let(:json_api_request_attributes) for shared_context :json_api_customer_v1_helpers'
  end

  let(:json_api_query_params) { nil }

  ## For create
  #  let(:json_api_request_attributes) { { name: 'new' } }

  ## For update
  #  let(:json_api_request_data) { super().merge(id: record_id) }
  #  let(:json_api_request_attributes) { { name: 'new' } }
end
