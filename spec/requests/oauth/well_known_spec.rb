# frozen_string_literal: true

RSpec.describe 'OAuth Authorization Server Metadata (RFC 8414)', type: :request do
  include_context :with_oauth_routes

  subject { get '/.well-known/oauth-authorization-server' }

  it 'returns JSON with all advertised endpoints' do
    subject
    expect(response).to have_http_status(:success)
    payload = JSON.parse(response.body)
    expect(payload['issuer']).to be_present
    expect(payload['authorization_endpoint']).to end_with('/oauth/authorize')
    expect(payload['token_endpoint']).to end_with('/oauth/token')
    expect(payload['registration_endpoint']).to end_with('/oauth/register')
    expect(payload['revocation_endpoint']).to end_with('/oauth/revoke')
    expect(payload['introspection_endpoint']).to end_with('/oauth/introspect')
    expect(payload['code_challenge_methods_supported']).to include('S256')
    expect(payload['grant_types_supported']).to include('authorization_code', 'refresh_token')
    expect(payload['response_types_supported']).to include('code')
  end

  # The OIDC gem's discovery routes claim this path too, and its version of the
  # document has no registration_endpoint — which is how MCP clients
  # self-register. config/routes.rb keeps our route first; this pins it, since
  # nothing else would fail if the ordering were swapped.
  it 'is served by yeti\'s own controller, not the OIDC gem\'s' do
    expect(Rails.application.routes.recognize_path('/.well-known/oauth-authorization-server'))
      .to include(controller: 'well_known/oauth_authorization_server')

    subject
    payload = JSON.parse(response.body)
    expect(payload['registration_endpoint']).to end_with('/oauth/register')
    expect(payload['service_documentation']).to be_present
  end

  it 'advertises the OIDC endpoints when yeti is also an OIDC provider' do
    subject
    payload = JSON.parse(response.body)
    expect(payload['jwks_uri']).to end_with('/oauth/discovery/keys')
    expect(payload['userinfo_endpoint']).to end_with('/oauth/userinfo')
    expect(payload['id_token_signing_alg_values_supported']).to include('RS256')
  end
end
