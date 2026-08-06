# frozen_string_literal: true

RSpec.describe 'OAuth Dynamic Client Registration (RFC 7591)', type: :request do
  include_context :with_oauth_routes

  def register(body)
    post '/oauth/register',
         params: body.to_json,
         headers: { 'Content-Type' => 'application/json' }
  end

  it 'creates a public client and returns client_id without secret' do
    register(
      client_name: 'Claude Code',
      redirect_uris: ['http://localhost:8080/callback'],
      grant_types: %w[authorization_code refresh_token],
      response_types: ['code'],
      token_endpoint_auth_method: 'none'
    )
    expect(response).to have_http_status(:created)
    body = JSON.parse(response.body)
    expect(body['client_id']).to be_present
    expect(body['client_secret']).to be_nil
    expect(body['token_endpoint_auth_method']).to eq('none')

    app = OauthApplication.find_by(uid: body['client_id'])
    expect(app.confidential).to be false
    expect(app.name).to eq('Claude Code')
  end

  it 'creates a confidential client and returns the secret once' do
    register(
      client_name: 'Web App',
      redirect_uris: ['https://example.test/cb'],
      token_endpoint_auth_method: 'client_secret_basic'
    )
    expect(response).to have_http_status(:created)
    body = JSON.parse(response.body)
    expect(body['client_secret']).to be_present

    app = OauthApplication.find_by(uid: body['client_id'])
    expect(app.confidential).to be true
  end

  it 'rejects an unsupported token_endpoint_auth_method with 400' do
    register(
      client_name: 'Post Client',
      redirect_uris: ['https://example.test/cb'],
      token_endpoint_auth_method: 'client_secret_post'
    )
    expect(response).to have_http_status(:bad_request)
    expect(JSON.parse(response.body)['error']).to eq('invalid_client_metadata')
    expect(OauthApplication.find_by(name: 'Post Client')).to be_nil
  end

  it 'grants the MCP scope when none is asked for' do
    register(client_name: 'Default Scope', redirect_uris: ['https://example.test/cb'])
    expect(response).to have_http_status(:created)
    expect(JSON.parse(response.body)['scope']).to eq('mcp')
  end

  # Self-registration exists for MCP clients. The OIDC scopes carry the admin's
  # email and roles and are registered by an operator through the admin UI, so a
  # stranger must not be able to mint a client that asks for them — see
  # SELF_REGISTRABLE_SCOPES.
  it 'rejects a self-registered client asking for the OIDC scopes' do
    register(
      client_name: 'Yeti Statistics',
      redirect_uris: ['https://evil.test/cb'],
      scope: 'openid profile email'
    )
    expect(response).to have_http_status(:bad_request)
    body = JSON.parse(response.body)
    expect(body['error']).to eq('invalid_client_metadata')
    expect(body['error_description']).to include('openid', 'profile', 'email')
    expect(OauthApplication.find_by(name: 'Yeti Statistics')).to be_nil
  end

  # Rejected wholesale rather than trimmed down to `mcp`: a client that asked for
  # an identity and was silently given API access instead has been told nothing.
  it 'rejects a mix of permitted and forbidden scopes rather than trimming it' do
    register(client_name: 'Mixed', redirect_uris: ['https://example.test/cb'], scope: 'mcp openid')
    expect(response).to have_http_status(:bad_request)
    expect(JSON.parse(response.body)['error_description']).to include('openid')
    expect(OauthApplication.find_by(name: 'Mixed')).to be_nil
  end

  it 'accepts an explicit request for the MCP scope' do
    register(client_name: 'Explicit', redirect_uris: ['https://example.test/cb'], scope: 'mcp')
    expect(response).to have_http_status(:created)
    expect(OauthApplication.find_by(name: 'Explicit').scopes.to_s).to eq('mcp')
  end

  it 'rejects malformed JSON with 400' do
    post '/oauth/register', params: 'not json',
                            headers: { 'Content-Type' => 'application/json' }
    expect(response).to have_http_status(:bad_request)
    expect(JSON.parse(response.body)['error']).to eq('invalid_request')
  end

  it 'rejects missing redirect_uris with 400' do
    register(client_name: 'X')
    expect(response).to have_http_status(:bad_request)
    expect(JSON.parse(response.body)['error']).to eq('invalid_client_metadata')
  end
end
