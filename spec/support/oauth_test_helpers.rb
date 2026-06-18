# frozen_string_literal: true

module OauthTestHelpers
  # Creates an OauthApplication. Defaults match a public MCP client
  # (PKCE-capable, no client secret needed).
  def create_oauth_application(name: 'Test Client', confidential: false, scopes: 'mcp', redirect_uri: 'http://localhost:8080/callback')
    OauthApplication.create!(
      name: name,
      redirect_uri: redirect_uri,
      scopes: scopes,
      confidential: confidential
    )
  end

  # Issues a valid access token for an admin. Returns the OauthAccessToken
  # record; the *plaintext* token is accessible via .plaintext_token while
  # the record is fresh (it's hashed in the column).
  def issue_access_token(admin:, application: nil, scopes: 'mcp', expires_in: 1.hour.to_i)
    application ||= create_oauth_application
    OauthAccessToken.create!(
      resource_owner_id: admin.id,
      application: application,
      scopes: scopes,
      expires_in: expires_in
    )
  end

  # POSTs a JSON-RPC body to /api/mcp with the given bearer token.
  def mcp_call(token:, method:, id: 1, params: nil)
    body = { jsonrpc: '2.0', id: id, method: method }
    body[:params] = params if params
    post '/api/mcp',
         params: body.to_json,
         headers: {
           'Authorization' => "Bearer #{token}",
           'Content-Type' => 'application/json'
         }
  end
end

RSpec.configure do |config|
  config.include OauthTestHelpers
end
