# frozen_string_literal: true

RSpec.describe 'MCP server auth + dispatch', type: :request do
  include_context :with_oauth_routes

  let(:admin) { create(:admin_user) }
  let(:application) { create_oauth_application(confidential: false) }
  let(:token) { issue_access_token(admin: admin, application: application) }

  # Clients that register without `scope` get Doorkeeper's default, which must
  # be the scope /api/mcp checks.
  it 'uses the MCP scope as the Doorkeeper default scope' do
    expect(Doorkeeper.config.default_scopes.to_a).to eq([Mcp::Server::REQUIRED_SCOPE])
  end

  describe 'authentication' do
    let(:resource_metadata) do
      'resource_metadata="http://www.example.com/.well-known/oauth-protected-resource/api/mcp"'
    end

    it 'rejects requests with no Authorization header' do
      post '/api/mcp', params: '{}', headers: { 'Content-Type' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)
      expect(response.headers['WWW-Authenticate']).to eq(%(Bearer #{resource_metadata}, scope="mcp"))
      expect(JSON.parse(response.body)).not_to have_key('error')
    end

    it 'rejects an unknown bearer token' do
      mcp_call(token: 'not-a-real-token', method: 'initialize')
      expect(response).to have_http_status(:unauthorized)
      expect(response.headers['WWW-Authenticate'])
        .to eq(%(Bearer #{resource_metadata}, scope="mcp", error="invalid_token"))
    end

    it 'accepts the Bearer scheme case-insensitively' do
      post '/api/mcp',
           params: { jsonrpc: '2.0', id: 1, method: 'tools/list' }.to_json,
           headers: { 'Authorization' => "bearer #{token.plaintext_token}", 'Content-Type' => 'application/json' }
      expect(response).to have_http_status(:ok)
    end

    it 'rejects a bearer header with trailing junk after the token' do
      mcp_call(token: "#{token.plaintext_token} junk", method: 'tools/list')
      expect(response).to have_http_status(:unauthorized)
      expect(response.headers['WWW-Authenticate']).to include('error="invalid_token"')
    end

    it 'escapes the request host inside the challenge quoted-string' do
      post '/api/mcp', params: '{}', headers: { 'Content-Type' => 'application/json', 'Host' => 'evil.example.com", error="x' }
      expect(response.headers['WWW-Authenticate'])
        .to start_with('Bearer resource_metadata="http://evil.example.com\\", error=\\"x/.well-known/')
    end

    it 'answers other methods with 405 and Allow: POST' do
      get '/api/mcp'
      expect(response).to have_http_status(:method_not_allowed)
      expect(response.headers['Allow']).to eq('POST')
    end

    # Doorkeeper revokes a rotated-out refresh token the first time its successor
    # access token is used — but only through its own token authentication.
    it 'revokes the previous refresh token once the refreshed access token is used' do
      old = OauthAccessToken.find_or_create_for(
        application: application, resource_owner: admin, scopes: 'mcp', expires_in: 3600, use_refresh_token: true
      )
      old_refresh = old.plaintext_refresh_token
      post '/oauth/token', params: { grant_type: 'refresh_token', refresh_token: old_refresh, client_id: application.uid }
      new_access = JSON.parse(response.body).fetch('access_token')
      expect(old.reload.revoked_at).to be_nil

      mcp_call(token: new_access, method: 'tools/list')
      expect(response).to have_http_status(:ok)
      expect(old.reload.revoked_at).to be_present

      post '/oauth/token', params: { grant_type: 'refresh_token', refresh_token: old_refresh, client_id: application.uid }
      expect(response).to have_http_status(:bad_request)
    end

    it 'rejects a token without the mcp scope with insufficient_scope' do
      tok = issue_access_token(admin: admin, application: application, scopes: 'openid')
      mcp_call(token: tok.plaintext_token, method: 'tools/list')
      expect(response).to have_http_status(:forbidden)
      expect(response.headers['WWW-Authenticate'])
        .to eq(%(Bearer #{resource_metadata}, scope="mcp", error="insufficient_scope"))
    end

    it 'rejects a revoked token' do
      token.revoke
      mcp_call(token: token.plaintext_token, method: 'tools/list')
      expect(response).to have_http_status(:unauthorized)
    end

    it 'rejects an expired token' do
      tok = issue_access_token(admin: admin, application: application, expires_in: 60)
      travel(2.hours) do
        mcp_call(token: tok.plaintext_token, method: 'tools/list')
        expect(response).to have_http_status(:unauthorized)
      end
    end

    it 'rejects a token for a disabled admin' do
      admin.update!(enabled: false)
      mcp_call(token: token.plaintext_token, method: 'tools/list')
      expect(response).to have_http_status(:unauthorized)
      expect(response.headers['WWW-Authenticate']).to include('error="invalid_token"')
    end

    it 'rejects a token for a deleted admin' do
      raw = token.plaintext_token
      admin.destroy
      mcp_call(token: raw, method: 'tools/list')
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'mcp.tools allowlist' do
    def stub_tools(value)
      allow(YetiConfig).to receive(:mcp).and_return(OpenStruct.new(enabled: true, tools: value))
    end

    def listed_tools
      mcp_call(token: token.plaintext_token, method: 'tools/list')
      JSON.parse(response.body).dig('result', 'tools').map { |t| t['name'] }
    end

    it 'exposes every tool when unset' do
      stub_tools(nil)

      expect(listed_tools).to match_array(Mcp::Tools::REGISTRY.keys)
    end

    it 'exposes only the listed tools' do
      stub_tools(['cdr_report'])

      expect(listed_tools).to eq(['cdr_report'])
    end

    it 'exposes nothing for an empty list' do
      stub_tools([])

      expect(listed_tools).to be_empty
    end

    # Hiding a tool from tools/list is not enough on its own.
    it 'refuses to call a tool that is not allowed' do
      stub_tools(['cdr_report'])
      mcp_call(
        token: token.plaintext_token,
        method: 'tools/call',
        params: { name: 'routing_simulate', arguments: {} }
      )

      expect(JSON.parse(response.body).dig('result', 'isError')).to be true
      expect(JSON.parse(response.body).dig('result', 'content', 0, 'text')).to match(/unknown tool/i)
    end

    it 'ignores an unknown name and says so in the log' do
      stub_tools(%w[cdr_report nope])
      expect(Rails.logger).to receive(:warn).with(/unknown tools: nope/)

      expect(listed_tools).to eq(['cdr_report'])
    end
  end

  describe 'JSON-RPC dispatch' do
    it 'responds to initialize' do
      mcp_call(token: token.plaintext_token, method: 'initialize')
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body['jsonrpc']).to eq('2.0')
      expect(body['result']['protocolVersion']).to be_present
      expect(body['result']['serverInfo']['name']).to eq('yeti-switch')
      expect(body['result']['serverInfo']['version']).to be_present
    end

    it 'responds to tools/list with at least routing_simulate' do
      mcp_call(token: token.plaintext_token, method: 'tools/list')
      expect(response).to have_http_status(:success)
      tools = JSON.parse(response.body).dig('result', 'tools')
      expect(tools.map { |t| t['name'] }).to include('routing_simulate')
    end

    it 'accepts notifications/* with a 202 and no body' do
      mcp_call(token: token.plaintext_token, method: 'notifications/initialized', id: nil)
      expect(response).to have_http_status(:accepted)
      expect(response.body).to be_blank
    end

    it 'returns JSON-RPC -32700 on malformed body' do
      post '/api/mcp',
           params: 'not json',
           headers: {
             'Authorization' => "Bearer #{token.plaintext_token}",
             'Content-Type' => 'application/json'
           }
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body.dig('error', 'code')).to eq(-32_700)
    end

    it 'returns JSON-RPC -32601 on unknown method' do
      mcp_call(token: token.plaintext_token, method: 'totally/unknown')
      body = JSON.parse(response.body)
      expect(body.dig('error', 'code')).to eq(-32_601)
    end
  end
end
