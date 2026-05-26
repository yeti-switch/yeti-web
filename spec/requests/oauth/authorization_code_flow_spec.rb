# frozen_string_literal: true

RSpec.describe 'OAuth authorization code flow', type: :request do
  include_context :with_oauth_routes
  include_context :login_as_admin

  let(:application) { create_oauth_application }
  let(:code_verifier) { SecureRandom.urlsafe_base64(64) }
  let(:code_challenge) { Base64.urlsafe_encode64(Digest::SHA256.digest(code_verifier), padding: false) }

  def authorize_params
    {
      response_type: 'code',
      client_id: application.uid,
      redirect_uri: application.redirect_uri,
      scope: 'mcp',
      code_challenge: code_challenge,
      code_challenge_method: 'S256',
      state: 'xyz'
    }
  end

  it 'renders the consent screen on GET /oauth/authorize' do
    get '/oauth/authorize', params: authorize_params
    expect(response).to have_http_status(:success)
  end

  it 'issues an authorization code and exchanges it for an access token' do
    # Approve consent
    post '/oauth/authorize', params: authorize_params
    expect(response).to have_http_status(:redirect)
    redirect = URI(response.location)
    code = CGI.parse(redirect.query)['code'].first
    expect(code).to be_present

    # Exchange code for tokens
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

  it 'rejects a reused authorization code' do
    post '/oauth/authorize', params: authorize_params
    code = CGI.parse(URI(response.location).query)['code'].first

    post '/oauth/token', params: {
      grant_type: 'authorization_code',
      code: code,
      client_id: application.uid,
      redirect_uri: application.redirect_uri,
      code_verifier: code_verifier
    }
    expect(response).to have_http_status(:success)

    # second exchange of the same code
    post '/oauth/token', params: {
      grant_type: 'authorization_code',
      code: code,
      client_id: application.uid,
      redirect_uri: application.redirect_uri,
      code_verifier: code_verifier
    }
    expect(response).to have_http_status(:bad_request)
    expect(JSON.parse(response.body)['error']).to eq('invalid_grant')
  end

  it 'rejects a wrong code_verifier (PKCE mismatch)' do
    post '/oauth/authorize', params: authorize_params
    code = CGI.parse(URI(response.location).query)['code'].first

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
