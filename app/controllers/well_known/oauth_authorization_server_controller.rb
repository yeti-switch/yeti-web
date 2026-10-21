# frozen_string_literal: true

# RFC 8414 OAuth 2.0 Authorization Server Metadata. MCP clients fetch this
# at /.well-known/oauth-authorization-server to discover yeti's OAuth endpoints
# without manual configuration. Required for Claude Code's "one-click connect".
module WellKnown
  class OauthAuthorizationServerController < ActionController::API
    include Issuer

    # The endpoints stay on request.base_url because the OIDC gem builds its own
    # discovery document from the request; two documents naming different hosts
    # for /oauth/authorize would be worse than an issuer mismatch.
    def show
      render json: {
        issuer: issuer,
        authorization_endpoint: "#{request.base_url}/oauth/authorize",
        token_endpoint: "#{request.base_url}/oauth/token",
        registration_endpoint: "#{request.base_url}/oauth/register",
        revocation_endpoint: "#{request.base_url}/oauth/revoke",
        introspection_endpoint: "#{request.base_url}/oauth/introspect",
        # Only what /oauth/register hands out: clients pick registration and
        # authorize scopes from here. OIDC relying parties read the gem's
        # /.well-known/openid-configuration, which lists every scope.
        scopes_supported: Oauth::RegistrationsController::SELF_REGISTRABLE_SCOPES,
        response_types_supported: %w[code],
        grant_types_supported: %w[authorization_code refresh_token],
        code_challenge_methods_supported: %w[S256],
        token_endpoint_auth_methods_supported: Oauth::RegistrationsController::SUPPORTED_AUTH_METHODS
      }.merge(oidc_metadata)
    end

    private

    # This document is served at a path the OIDC gem would otherwise claim (see
    # config/routes.rb), so a client reading only it must not conclude there is
    # no OIDC on offer.
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
