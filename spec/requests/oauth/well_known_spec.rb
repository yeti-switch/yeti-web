# frozen_string_literal: true

RSpec.describe 'OAuth Authorization Server Metadata (RFC 8414)', type: :request do
  include_context :with_oauth_routes

  subject { get '/.well-known/oauth-authorization-server' }

  it 'returns JSON with all advertised endpoints' do
    subject
    expect(response).to have_http_status(:success)
    payload = JSON.parse(response.body)
    expect(payload['issuer']).to eq(YetiConfig.oauth.issuer)
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

  # This document advertises jwks_uri and userinfo_endpoint, so a client may
  # discover here and validate an id_token minted against the OIDC document's
  # issuer. If the two disagree, every such login fails on issuer mismatch.
  it 'claims the same issuer as the OIDC discovery document' do
    subject
    rfc8414 = JSON.parse(response.body)

    get '/.well-known/openid-configuration'
    openid = JSON.parse(response.body)

    expect(rfc8414['issuer']).to eq(openid['issuer'])
    # yeti_web.yml.ci sets issuer and the request host to different values.
    expect(rfc8414['issuer']).to eq(YetiConfig.oauth.issuer)
    expect(rfc8414['issuer']).not_to eq('http://www.example.com')
  end

  # The MCP-only deployment: oauth.enabled with no issuer configured, so nothing
  # to compare an id_token against and one-click connect stays zero-config.
  context 'when oauth.issuer is not configured' do
    before { allow(YetiConfig.oauth).to receive(:issuer).and_return(nil) }

    it 'falls back to the request base URL' do
      subject
      expect(JSON.parse(response.body)['issuer']).to eq('http://www.example.com')
    end
  end
end
