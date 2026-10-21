# frozen_string_literal: true

# RFC 9728 OAuth 2.0 Protected Resource Metadata for the MCP endpoint. MCP
# clients read scopes_supported here before falling back to the authorization
# server's list, which also carries the OIDC scopes that /oauth/register refuses.
module WellKnown
  class OauthProtectedResourceController < ActionController::API
    include Issuer

    def show
      render json: {
        resource: "#{request.base_url}#{Mcp::Server::MOUNT_PATH}",
        authorization_servers: [issuer],
        scopes_supported: [Mcp::Server::REQUIRED_SCOPE],
        bearer_methods_supported: %w[header],
        resource_name: Mcp::Server::SERVER_NAME
      }
    end
  end
end
