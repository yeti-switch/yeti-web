# frozen_string_literal: true

RSpec.describe 'OAuth authorization code flow', type: :request do
  include_context :with_oauth_routes
  include_context :login_as_admin

  let(:admin) { create(:admin_user) }
  let(:application) { create_oauth_application }
  let(:code_verifier) { SecureRandom.urlsafe_base64(64) }
  let(:code_challenge) { Base64.urlsafe_encode64(Digest::SHA256.digest(code_verifier), padding: false) }

  # Yeti's test env has allow_forgery_protection: true, so POSTing the consent
  # form (POST /oauth/authorize) without a CSRF token from a real session
  # fails. We bypass the user-facing consent step by issuing the AccessGrant
  # directly — this still exercises every server-side bit of the auth code
  # flow that we own (PKCE check, code reuse rejection, exchange path).
  # The browser-side consent UI is covered separately by feature specs.
  def create_authorization_code
    grant = OauthAccessGrant.create!(
      application: application,
      resource_owner_id: admin.id,
      expires_in: 600,
      redirect_uri: application.redirect_uri,
      scopes: 'mcp',
      code_challenge: code_challenge,
      code_challenge_method: 'S256'
    )
    grant.plaintext_token
  end

  context 'GET /oauth/authorize (consent screen)' do
    include_context :login_as_admin

    it 'renders the consent screen for a logged-in admin' do
      get '/oauth/authorize', params: {
        response_type: 'code',
        client_id: application.uid,
        redirect_uri: application.redirect_uri,
        scope: 'mcp',
        code_challenge: code_challenge,
        code_challenge_method: 'S256',
        state: 'xyz'
      }
      expect(response).to have_http_status(:success)
    end
  end

  it 'exchanges an authorization code for an access token' do
    code = create_authorization_code
    post '/oauth/token', params: {
      grant_type: 'authorization_code',
      code: code,
      client_id: application.uid,
      redirect_uri: application.redirect_uri,
      code_verifier: code_verifier
    }
    expect(response).to have_http_status(:success)
    body = JSON.parse(response.body)
    expect(body['access_token']).to be_present
    expect(body['refresh_token']).to be_present
    expect(body['expires_in']).to eq(3600)
    expect(body['token_type']).to eq('Bearer')
  end

  it 'rejects the code exchange when the AdminUser is disabled' do
    code = create_authorization_code
    admin.update!(enabled: false)
    post '/oauth/token', params: {
      grant_type: 'authorization_code',
      code: code,
      client_id: application.uid,
      redirect_uri: application.redirect_uri,
      code_verifier: code_verifier
    }
    expect(response).to have_http_status(:bad_request)
    # before_successful_strategy_response reads request.grant.resource_owner_id
    # (request.resource_owner is private) and raises 'invalid_grant'.
    expect(JSON.parse(response.body)['error']).to eq('invalid_grant')
  end

  it 'rejects a reused authorization code' do
    code = create_authorization_code
    2.times do
      post '/oauth/token', params: {
        grant_type: 'authorization_code',
        code: code,
        client_id: application.uid,
        redirect_uri: application.redirect_uri,
        code_verifier: code_verifier
      }
    end
    expect(response).to have_http_status(:bad_request)
    expect(JSON.parse(response.body)['error']).to eq('invalid_grant')
  end

  it 'rejects a wrong code_verifier (PKCE mismatch)' do
    code = create_authorization_code
    post '/oauth/token', params: {
      grant_type: 'authorization_code',
      code: code,
      client_id: application.uid,
      redirect_uri: application.redirect_uri,
      code_verifier: 'not-the-real-verifier'
    }
    expect(response).to have_http_status(:bad_request)
    expect(JSON.parse(response.body)['error']).to eq('invalid_grant')
  end
end
