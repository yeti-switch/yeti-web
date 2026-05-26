# frozen_string_literal: true

# When an unauthenticated user hits /oauth/authorize, the resource_owner
# authenticator in config/initializers/doorkeeper.rb stores the full URL
# (including OAuth params) under Devise's scoped return-to key, then redirects
# to the admin login. After successful sign-in, Devise's default
# `after_sign_in_path_for` reads `stored_location_for(:admin_user)` and
# bounces the user back here — the OAuth flow then continues from the consent
# screen with the original code_challenge / state / scope intact.
RSpec.describe 'OAuth authorize when not signed in', type: :request do
  include_context :with_oauth_routes

  let(:application) { create_oauth_application }
  let(:code_verifier) { SecureRandom.urlsafe_base64(64) }
  let(:code_challenge) { Base64.urlsafe_encode64(Digest::SHA256.digest(code_verifier), padding: false) }
  let(:authorize_params) do
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

  it 'redirects to the Devise login form' do
    get '/oauth/authorize', params: authorize_params
    expect(response).to redirect_to(new_admin_user_session_path)
  end

  it 'stores the authorize URL under Devise’s scoped return-to key' do
    get '/oauth/authorize', params: authorize_params
    # The scope is :admin_user, so the key MUST be "admin_user_return_to".
    # If this assertion fails, sign-in will send the user to /admin/dashboard
    # instead of back to /oauth/authorize and the OAuth flow will silently break.
    stored = session['admin_user_return_to']
    expect(stored).to be_present
    expect(stored).to start_with('/oauth/authorize')
    expect(stored).to include("client_id=#{application.uid}")
    expect(stored).to include('code_challenge=')
    expect(stored).to include('state=xyz')
  end

  it 'sets a flash notice prompting sign-in' do
    get '/oauth/authorize', params: authorize_params
    expect(flash[:notice]).to match(/sign in/i)
  end

  it 'when already signed in, skips the redirect and renders the consent screen' do
    admin = create(:admin_user)
    login_as(admin, scope: :admin_user)
    get '/oauth/authorize', params: authorize_params
    expect(response).to have_http_status(:success)
  end
end
