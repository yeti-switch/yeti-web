# frozen_string_literal: true

# RFC 8414 OAuth 2.0 Authorization Server Metadata. MCP clients fetch this
# at /.well-known/oauth-authorization-server to discover yeti's OAuth endpoints
# without manual configuration. Required for Claude Code's "one-click connect".
module WellKnown
  class OauthAuthorizationServerController < ActionController::API
    def show
      render json: {
        issuer: issuer,
        authorization_endpoint: "#{request.base_url}/oauth/authorize",
        token_endpoint: "#{request.base_url}/oauth/token",
        registration_endpoint: "#{request.base_url}/oauth/register",
        revocation_endpoint: "#{request.base_url}/oauth/revoke",
        introspection_endpoint: "#{request.base_url}/oauth/introspect",
        scopes_supported: Doorkeeper.config.scopes.all,
        response_types_supported: %w[code],
        grant_types_supported: %w[authorization_code refresh_token],
        code_challenge_methods_supported: %w[S256],
        token_endpoint_auth_methods_supported: %w[none client_secret_basic],
        service_documentation: "#{request.base_url}/api/mcp"
      }.merge(oidc_metadata)
    end

    private

    # The one identity this authorization server claims — the same string the
    # OIDC discovery document reports and every id_token carries in `iss`, so a
    # client that discovers here and validates a token there sees no mismatch.
    # Emitted verbatim: clients compare it byte for byte, so normalising a
    # trailing slash away here would break exactly the logins it looks like it
    # fixes.
    #
    # Falls back to the request's own base URL when unset, which is the MCP-only
    # deployment: oauth.enabled with no oidc block, nothing to compare against,
    # zero config. oauth.issuer is mandatory once OIDC is on — see
    # config/initializers/doorkeeper_openid_connect.rb.
    #
    # The endpoints below deliberately stay on request.base_url: the OIDC gem
    # builds its own discovery document from Rails URL helpers, i.e. from the
    # request, and two documents advertising different hosts for /oauth/authorize
    # would be a worse failure than the one this avoids. If a proxy really does
    # rewrite host or scheme, fix it with X-Forwarded-* / default_url_options.
    def issuer
      YetiConfig.oauth&.issuer.presence || request.base_url
    end

    # When yeti is also an OIDC provider, say so here. A client that reads only
    # this document (it is served at a path the OIDC gem would otherwise claim
    # — see config/routes.rb) should not conclude there is no OIDC on offer.
    # The authoritative OIDC document is /.well-known/openid-configuration.
    def oidc_metadata
      return {} unless YetiConfig.oauth&.oidc&.enabled

      {
        jwks_uri: "#{request.base_url}/oauth/discovery/keys",
        userinfo_endpoint: "#{request.base_url}/oauth/userinfo",
        id_token_signing_alg_values_supported: %w[RS256],
        subject_types_supported: %w[public]
      }
    end
  end
end
