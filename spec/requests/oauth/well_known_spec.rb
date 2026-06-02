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
end
