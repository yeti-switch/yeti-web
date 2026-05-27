# frozen_string_literal: true

RSpec.describe 'OAuth refresh token + disabled-admin guard', type: :request do
  include_context :with_oauth_routes

  let(:admin) { create(:admin_user) }
  let(:application) { create_oauth_application(confidential: false) }
  let!(:token) do
    # find_or_create_for uses the full Doorkeeper logic, so the refresh token
    # is actually issued (use_refresh_token is a config flag, not a column —
    # passing it to .create! does nothing).
    OauthAccessToken.find_or_create_for(
      application: application,
      resource_owner: admin,
      scopes: 'mcp',
      expires_in: 3600,
      use_refresh_token: true
    )
  end

  it 'issues a new access token from a valid refresh token' do
    post '/oauth/token', params: {
      grant_type: 'refresh_token',
      refresh_token: token.plaintext_refresh_token,
      client_id: application.uid
    }
    expect(response).to have_http_status(:success)
    body = JSON.parse(response.body)
    expect(body['access_token']).to be_present
    expect(body['access_token']).not_to eq(token.token)
  end

  it 'rejects refresh when the AdminUser is disabled' do
    admin.update!(enabled: false)
    post '/oauth/token', params: {
      grant_type: 'refresh_token',
      refresh_token: token.plaintext_refresh_token,
      client_id: application.uid
    }
    expect(response).to have_http_status(:bad_request)
    # The before_successful_strategy_response hook in doorkeeper.rb raises
    # with this message; Doorkeeper surfaces it as the OAuth error code.
    expect(JSON.parse(response.body)['error']).to eq('resource_owner_disabled')
  end

  it 'rejects refresh when the AdminUser has been deleted (cascade)' do
    refresh = token.plaintext_refresh_token
    admin.destroy
    post '/oauth/token', params: {
      grant_type: 'refresh_token',
      refresh_token: refresh,
      client_id: application.uid
    }
    expect(response).to have_http_status(:bad_request)
  end
end
