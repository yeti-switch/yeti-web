# frozen_string_literal: true

module Mcp
  # Streamable HTTP transport for the Model Context Protocol.
  # Hand-rolled because the Ruby MCP SDK ecosystem is still young and we
  # only need three JSON-RPC methods: initialize, tools/list, tools/call.
  # Plus the notifications/initialized one-way notification.
  # See https://spec.modelcontextprotocol.io for the wire format.
  #
  # Auth: OAuth 2.1 access tokens via Doorkeeper. Clients obtain tokens
  # through the standard authorization-code-with-PKCE flow against the
  # endpoints advertised at /.well-known/oauth-authorization-server.
  class Server
    PROTOCOL_VERSION = '2025-06-18'
    SERVER_INFO = { name: 'yeti-mcp', version: '0.1.0' }.freeze

    def call(env)
      req = Rack::Request.new(env)
      return [405, { 'Content-Type' => 'text/plain' }, ['Method Not Allowed']] unless req.post?

      admin_user = authenticate!(req)
      return unauthorized_response if admin_user.nil?

      body = req.body.read
      message = JSON.parse(body)

      if message['method'].to_s.start_with?('notifications/')
        return [202, {}, ['']]
      end

      Current.admin_user = admin_user if defined?(Current) && Current.respond_to?(:admin_user=)
      result = dispatch(message)
      json_response(message['id'], result)
    rescue JSON::ParserError => e
      Rails.logger.warn("[MCP] parse error: #{e.message}")
      json_response(nil, error: { code: -32_700, message: 'Parse error' })
    ensure
      Current.admin_user = nil if defined?(Current) && Current.respond_to?(:admin_user=)
    end

    private

    # Returns the AdminUser this token belongs to, or nil if the token is
    # missing/invalid/expired/revoked, or its admin is disabled.
    def authenticate!(req)
      header = req.get_header('HTTP_AUTHORIZATION').to_s
      return nil unless header.start_with?('Bearer ')

      raw_token = header.sub(/\ABearer\s+/, '')
      access_token = OauthAccessToken.by_token(raw_token)
      return nil if access_token.nil? || !access_token.accessible?

      admin_user = AdminUser.find_by(id: access_token.resource_owner_id)
      return nil if admin_user.nil? || !admin_user.enabled?

      admin_user
    end

    def unauthorized_response
      body = { error: 'invalid_token', error_description: 'Missing, invalid, or expired access token' }.to_json
      headers = {
        'Content-Type' => 'application/json',
        'WWW-Authenticate' => 'Bearer realm="yeti-mcp", error="invalid_token"'
      }
      [401, headers, [body]]
    end

    def dispatch(message)
      case message['method']
      when 'initialize'
        {
          result: {
            protocolVersion: PROTOCOL_VERSION,
            capabilities: { tools: { listChanged: false } },
            serverInfo: SERVER_INFO
          }
        }
      when 'tools/list'
        { result: { tools: Tools.list } }
      when 'tools/call'
        name = message.dig('params', 'name')
        args = message.dig('params', 'arguments') || {}
        { result: Tools.call(name, args) }
      else
        { error: { code: -32_601, message: "Method not found: #{message['method']}" } }
      end
    end

    def json_response(id, payload)
      body = { jsonrpc: '2.0', id: id }.merge(payload).to_json
      [200, { 'Content-Type' => 'application/json' }, [body]]
    end
  end
end
