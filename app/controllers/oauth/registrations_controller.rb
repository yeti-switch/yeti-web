# frozen_string_literal: true

# RFC 7591 Dynamic Client Registration. MCP clients (Claude Code, Cursor, ...)
# hit this to self-register before initiating the OAuth flow. Unauthenticated
# by design — registration alone doesn't grant access; the user still has to
# sign in and consent. Add rate limiting at the reverse proxy layer in prod.
module Oauth
  class RegistrationsController < ActionController::API
    # Only the two methods we advertise in /.well-known/oauth-authorization-server
    # are supported. `nil` / missing = public client (treated as 'none').
    SUPPORTED_AUTH_METHODS = %w[none client_secret_basic].freeze

    # What a stranger may register itself for. This endpoint exists to serve MCP
    # clients, so it grants the MCP scope and nothing else — in particular not
    # the OIDC scopes (doorkeeper.rb), which carry the admin's email and roles
    # and are meant to be registered by an operator through the admin UI (see
    # app/admin/system/oauth_applications.rb). Without this the split is only a
    # convention: anyone could self-register a plausibly-named client asking for
    # `openid profile email` and collect an identity from the first admin who
    # approves what looks like an ordinary sign-in prompt.
    #
    # Enforced here rather than at /oauth/authorize because this is the only
    # unauthenticated way to create an application: the admin UI is authenticated
    # and root-gated, Doorkeeper's own applications controller is not mounted
    # (skip_controllers :applications), and there is no RFC 7592 endpoint to
    # widen a client's scopes afterwards.
    SELF_REGISTRABLE_SCOPES = %w[mcp].freeze

    def create
      params = JSON.parse(request.body.read)

      auth_method = params['token_endpoint_auth_method'].presence || 'none'
      unless SUPPORTED_AUTH_METHODS.include?(auth_method)
        return render json: {
          error: 'invalid_client_metadata',
          error_description: "Unsupported token_endpoint_auth_method: #{auth_method}. Supported: #{SUPPORTED_AUTH_METHODS.join(', ')}"
        }, status: 400
      end

      # RFC 7591 §3.2.1 also allows quietly returning a narrower `scope` than was
      # asked for, but a client that is told what it may have can act on it,
      # whereas one handed a silently trimmed scope only finds out later, at the
      # token endpoint, with nothing to point at.
      requested_scopes = params['scope'].to_s.split
      unsupported_scopes = requested_scopes - SELF_REGISTRABLE_SCOPES
      if unsupported_scopes.any?
        return render json: {
          error: 'invalid_client_metadata',
          error_description: "Unsupported scope: #{unsupported_scopes.join(' ')}. " \
                             "Dynamic registration may request: #{SELF_REGISTRABLE_SCOPES.join(' ')}. " \
                             'Other scopes are registered by an administrator.'
        }, status: 400
      end

      app = OauthApplication.new(
        name: params['client_name'].to_s[0, 100].presence || 'Unnamed client',
        redirect_uri: Array(params['redirect_uris']).join("\n"),
        scopes: requested_scopes.presence&.join(' ') || Doorkeeper.config.default_scopes.to_s,
        confidential: auth_method != 'none'
      )

      if app.save
        render json: registration_response(app, params, auth_method), status: 201
      else
        render json: { error: 'invalid_client_metadata', error_description: app.errors.full_messages.join('; ') },
               status: 400
      end
    rescue JSON::ParserError
      render json: { error: 'invalid_request', error_description: 'Request body must be JSON' },
             status: 400
    end

    private

    def registration_response(app, params, auth_method)
      {
        client_id: app.uid,
        client_secret: app.confidential? ? app.plaintext_secret : nil,
        client_id_issued_at: app.created_at.to_i,
        client_secret_expires_at: 0, # never
        client_name: app.name,
        redirect_uris: app.redirect_uri.to_s.split("\n"),
        grant_types: Array(params['grant_types']).presence || %w[authorization_code refresh_token],
        response_types: Array(params['response_types']).presence || %w[code],
        token_endpoint_auth_method: auth_method,
        scope: app.scopes.to_s
      }.compact
    end
  end
end
