# frozen_string_literal: true

RSpec.describe 'OAuth + MCP config gating', type: :request do
  # An absent route may either raise ActionController::RoutingError or render
  # a 404 depending on path and verb (Rails' show_exceptions middleware
  # rescues some routing errors and re-raises others). Accept both.
  def expect_route_absent
    yield
    expect(response).to have_http_status(:not_found)
  rescue ActionController::RoutingError
    :ok
  end

  describe 'when oauth.enabled is false' do
    include_context :with_oauth_routes_disabled

    it 'has no /.well-known/oauth-authorization-server route' do
      expect_route_absent { get '/.well-known/oauth-authorization-server' }
    end

    it 'has no /oauth/authorize route' do
      expect_route_absent { get '/oauth/authorize' }
    end

    it 'has no /api/mcp route' do
      expect_route_absent { post '/api/mcp', params: '{}', headers: { 'Content-Type' => 'application/json' } }
    end
  end

  describe 'when oauth.enabled is true but mcp.enabled is false' do
    before do
      @__orig_mcp = YetiConfig.mcp.enabled
      YetiConfig.mcp.enabled = false
      Rails.application.reload_routes!
    end

    after do
      YetiConfig.mcp.enabled = @__orig_mcp
      Rails.application.reload_routes!
    end

    it 'serves /.well-known/oauth-authorization-server' do
      get '/.well-known/oauth-authorization-server'
      expect(response).to have_http_status(:success)
    end

    it 'has no /api/mcp route when mcp is off (oauth still on)' do
      expect_route_absent { post '/api/mcp', params: '{}', headers: { 'Content-Type' => 'application/json' } }
    end
  end
end
