# frozen_string_literal: true

module Mcp
  # Streamable HTTP transport for the Model Context Protocol.
  # Hand-rolled because the Ruby MCP SDK ecosystem is still young and we
  # only need three JSON-RPC methods: initialize, tools/list, tools/call.
  # Plus the notifications/initialized one-way notification.
  # See https://spec.modelcontextprotocol.io for the wire format.
  #
  # Auth: OAuth 2.1 access tokens via Doorkeeper. Clients discover the
  # authorization server through /.well-known/oauth-protected-resource (also
  # named in every 401/403) and obtain tokens with authorization code + PKCE.
  class Server
    PROTOCOL_VERSION = '2025-06-18'
    SERVER_NAME = 'yeti-switch'
    MOUNT_PATH = '/api/mcp'
    REQUIRED_SCOPE = 'mcp'
    # Resolved once at class load — app is restarted on every upgrade, so the
    # version can't drift during a process's lifetime.
    SERVER_INFO = {
      name: SERVER_NAME,
      version: Rails.application.config.app_build_info.fetch('version', 'unknown')
    }.freeze

    def call(env)
      req = ActionDispatch::Request.new(env)
      return [405, { 'Content-Type' => 'text/plain', 'Allow' => 'POST' }, ['Method Not Allowed']] unless req.post?

      auth_error = authentication_error(req)
      return auth_error_response(req, auth_error) if auth_error

      body = req.body.read
      message = JSON.parse(body)
      unless message.is_a?(Hash)
        return json_response(nil, error: { code: -32_600, message: 'Invalid Request' })
      end

      if message['method'].to_s.start_with?('notifications/')
        return [202, {}, ['']]
      end

      result = dispatch(message)
      json_response(message['id'], result)
    rescue JSON::ParserError => e
      Rails.logger.warn("[MCP] parse error: #{e.message}")
      json_response(nil, error: { code: -32_700, message: 'Parse error' })
    end

    private

    # nil when the request carries a usable token, otherwise the reason:
    # :missing (no bearer token), :invalid_token (unknown/expired/revoked token,
    # disabled or deleted admin), :insufficient_scope (token lacks `mcp`).
    def authentication_error(req)
      raw_token = req.get_header('HTTP_AUTHORIZATION').to_s[/\ABearer\s+(\S+)/i, 1]
      return :missing if raw_token.nil?

      access_token = OauthAccessToken.by_token(raw_token)
      return :invalid_token if access_token.nil?

      # Doorkeeper::OAuth::Token.authenticate does this for its own endpoints;
      # without it the refresh token rotated out stays usable forever.
      access_token.revoke_previous_refresh_token! if Doorkeeper.config.refresh_token_enabled?
      # accessible? also checks the owning admin is enabled.
      return :invalid_token if access_token.resource_owner_id.nil? || !access_token.accessible?
      # Require the `mcp` scope explicitly so future tokens issued for other
      # scopes (e.g. SSO via the same OAuth server) can't call MCP.
      return :insufficient_scope unless access_token.scopes.include?(REQUIRED_SCOPE)

      nil
    end

    AUTH_ERRORS = {
      missing: [401, nil, 'Access token required'],
      invalid_token: [401, 'invalid_token', 'Invalid, expired, or revoked access token'],
      insufficient_scope: [403, 'insufficient_scope', "Access token lacks the #{REQUIRED_SCOPE} scope"]
    }.freeze
    private_constant :AUTH_ERRORS

    # RFC 6750 §3 + RFC 9728 §5.1. A request without credentials gets no error
    # code, only the pointers needed to start the OAuth flow.
    def auth_error_response(req, reason)
      status, error, description = AUTH_ERRORS.fetch(reason)
      metadata_url = "#{req.base_url}/.well-known/oauth-protected-resource#{MOUNT_PATH}"
      challenge = [
        %(resource_metadata="#{quoted_string(metadata_url)}"),
        %(scope="#{REQUIRED_SCOPE}")
      ]
      challenge << %(error="#{error}") if error
      headers = {
        'Content-Type' => 'application/json',
        'WWW-Authenticate' => "Bearer #{challenge.join(', ')}"
      }
      [status, headers, [{ error: error, error_description: description }.compact.to_json]]
    end

    # RFC 9110 §5.6.4. base_url carries the raw Host / X-Forwarded-Host.
    def quoted_string(value)
      value.gsub(/["\\]/) { |char| "\\#{char}" }
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
