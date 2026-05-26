# frozen_string_literal: true

RSpec.describe 'OAuth + MCP config gating', type: :request do
  describe 'when oauth.enabled is false' do
    include_context :with_oauth_routes_disabled

    it 'returns 404 for /.well-known/oauth-authorization-server' do
      get '/.well-known/oauth-authorization-server'
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for /oauth/authorize' do
      get '/oauth/authorize'
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for /api/mcp' do
      post '/api/mcp', params: '{}', headers: { 'Content-Type' => 'application/json' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'when oauth.enabled is true but mcp.enabled is false' do
    before do
      allow(YetiConfig).to receive(:oauth).and_return(OpenStruct.new(enabled: true))
      allow(YetiConfig).to receive(:mcp).and_return(OpenStruct.new(enabled: false))
      Rails.application.reload_routes!
    end

    after { Rails.application.reload_routes! }

    it 'serves /.well-known/oauth-authorization-server' do
      get '/.well-known/oauth-authorization-server'
      expect(response).to have_http_status(:success)
    end

    it 'returns 404 for /api/mcp' do
      post '/api/mcp', params: '{}', headers: { 'Content-Type' => 'application/json' }
      expect(response).to have_http_status(:not_found)
    end
  end
end
