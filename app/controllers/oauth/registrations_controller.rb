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

    def create
      params = JSON.parse(request.body.read)

      auth_method = params['token_endpoint_auth_method'].presence || 'none'
      unless SUPPORTED_AUTH_METHODS.include?(auth_method)
        return render json: {
          error: 'invalid_client_metadata',
          error_description: "Unsupported token_endpoint_auth_method: #{auth_method}. Supported: #{SUPPORTED_AUTH_METHODS.join(', ')}"
        }, status: 400
      end

      app = OauthApplication.new(
        name: params['client_name'].to_s[0, 100].presence || 'Unnamed client',
        redirect_uri: Array(params['redirect_uris']).join("\n"),
        scopes: params['scope'].presence || Doorkeeper.config.default_scopes.to_s,
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
