# frozen_string_literal: true

RSpec.shared_context :stub_request_to_create_phone_systems_session do
  let(:phone_systems_base_url) { 'https://api.telecom.center' }
  let(:phone_systems_query_params) { { token: 'asdf.asdf.asdf', redirect_to: :phone_systems, from: :rspec } }
  let(:phone_systems_redirect_url) { "https://sandbox.phone.systems/auth#{phone_systems_query_params.to_query}" }
  # the Customer ID from Phone Systems and The service ID from Yeti WEB should be the same
  let(:service_id) { service.id }
  let(:response_from_phone_systems) do
    {
      data: {
        id: 99,
        type: :sessions,
        attributes: {
          uri: phone_systems_redirect_url
        }
      }
    }
  end
  let(:stub_request_to_create_phone_systems_session) do
    stub_request(:post, "#{phone_systems_base_url}/api/rest/public/operator/sessions")
      .with(
        body: { data: { type: 'sessions', relationships: { customer: { data: { type: :customers, id: service_id } } } } }.to_json
      )
      .to_return(
        status: 200, body: response_from_phone_systems.to_json, headers: {}
      )
  end
end
