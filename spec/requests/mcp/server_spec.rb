# frozen_string_literal: true

RSpec.describe 'MCP server auth + dispatch', type: :request do
  include_context :with_oauth_routes

  let(:admin) { create(:admin_user) }
  let(:application) { create_oauth_application(confidential: false) }
  let(:token) { issue_access_token(admin: admin, application: application) }

  describe 'authentication' do
    it 'rejects requests with no Authorization header' do
      post '/api/mcp', params: '{}', headers: { 'Content-Type' => 'application/json' }
      expect(response).to have_http_status(:unauthorized)
      expect(response.headers['WWW-Authenticate']).to include('Bearer')
    end

    it 'rejects an unknown bearer token' do
      mcp_call(token: 'not-a-real-token', method: 'initialize')
      expect(response).to have_http_status(:unauthorized)
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
    end

    it 'rejects a token for a deleted admin' do
      raw = token.plaintext_token
      admin.destroy
      mcp_call(token: raw, method: 'tools/list')
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'JSON-RPC dispatch' do
    it 'responds to initialize' do
      mcp_call(token: token.plaintext_token, method: 'initialize')
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body['jsonrpc']).to eq('2.0')
      expect(body['result']['protocolVersion']).to be_present
      expect(body['result']['serverInfo']['name']).to eq('yeti-mcp')
    end

    it 'responds to tools/list with at least routing.simulate' do
      mcp_call(token: token.plaintext_token, method: 'tools/list')
      expect(response).to have_http_status(:success)
      tools = JSON.parse(response.body).dig('result', 'tools')
      expect(tools.map { |t| t['name'] }).to include('routing.simulate')
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
