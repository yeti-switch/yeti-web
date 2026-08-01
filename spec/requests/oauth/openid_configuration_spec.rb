# frozen_string_literal: true

RSpec.describe 'OIDC discovery', type: :request do
  include_context :with_oauth_routes

  describe 'GET /.well-known/openid-configuration' do
    subject { get '/.well-known/openid-configuration' }

    let(:payload) { JSON.parse(response.body) }

    it 'advertises the endpoints and algorithms a client needs' do
      subject
      expect(response).to have_http_status(:success)

      # A client compares this against the URL it was configured with and
      # against the id_token's iss; all three must be identical.
      expect(payload['issuer']).to eq(YetiConfig.oauth.oidc.issuer)

      expect(payload['authorization_endpoint']).to end_with('/oauth/authorize')
      expect(payload['token_endpoint']).to end_with('/oauth/token')
      expect(payload['jwks_uri']).to end_with('/oauth/discovery/keys')
      expect(payload['userinfo_endpoint']).to end_with('/oauth/userinfo')

      expect(payload['id_token_signing_alg_values_supported']).to include('RS256')
      expect(payload['response_types_supported']).to include('code')
      expect(payload['code_challenge_methods_supported']).to include('S256')
      expect(payload['scopes_supported']).to include('openid')
      expect(payload['subject_types_supported']).to include('public')
    end
  end

  describe 'GET /oauth/discovery/keys' do
    subject { get '/oauth/discovery/keys' }

    it 'publishes a public signing key' do
      subject
      expect(response).to have_http_status(:success)

      keys = JSON.parse(response.body)['keys']
      expect(keys.size).to eq(1)
      expect(keys.first).to include('kty' => 'RSA', 'alg' => 'RS256', 'use' => 'sig')
      # The kid is how a client picks the right key across a rotation.
      expect(keys.first['kid']).to be_present
      # Public half only — the private key must never leave the server.
      expect(keys.first).not_to have_key('d')
    end
  end
end
