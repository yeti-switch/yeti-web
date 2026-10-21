# frozen_string_literal: true

RSpec.describe 'OAuth Protected Resource Metadata (RFC 9728)', type: :request do
  include_context :with_oauth_routes

  it 'describes the MCP resource' do
    get '/.well-known/oauth-protected-resource/api/mcp'
    expect(response).to have_http_status(:success)
    payload = JSON.parse(response.body)
    expect(payload['resource']).to eq('http://www.example.com/api/mcp')
    expect(payload['scopes_supported']).to eq(['mcp'])
    expect(payload['bearer_methods_supported']).to eq(['header'])
  end

  # RFC 9728 §3.3: a document's `resource` must match the identifier its URL was
  # built from, so the root URL may only describe the host itself.
  it 'serves no root document' do
    get '/.well-known/oauth-protected-resource'
    expect(response).to have_http_status(:not_found)
  end

  # Clients fetch <authorization_server>/.well-known/oauth-authorization-server
  # and check its issuer against the value listed here.
  it 'names the authorization server by the issuer its own metadata claims' do
    get '/.well-known/oauth-protected-resource/api/mcp'
    authorization_servers = JSON.parse(response.body)['authorization_servers']

    get '/.well-known/oauth-authorization-server'
    expect(authorization_servers).to eq([JSON.parse(response.body)['issuer']])
  end

  context 'when oauth.issuer is not configured' do
    before { allow(YetiConfig.oauth).to receive(:issuer).and_return(nil) }

    it 'falls back to the request base URL' do
      get '/.well-known/oauth-protected-resource/api/mcp'
      expect(JSON.parse(response.body)['authorization_servers']).to eq(['http://www.example.com'])
    end
  end
end
