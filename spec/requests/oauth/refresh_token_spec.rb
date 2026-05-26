# frozen_string_literal: true

RSpec.describe 'OAuth refresh token + disabled-admin guard', type: :request do
  include_context :with_oauth_routes

  let(:admin) { create(:admin_user) }
  let(:application) { create_oauth_application(confidential: false) }
  let!(:token) do
    OauthAccessToken.create!(
      resource_owner_id: admin.id,
      application: application,
      scopes: 'mcp',
      expires_in: 3600,
      use_refresh_token: true
    )
  end

  it 'issues a new access token from a valid refresh token' do
    post '/oauth/token', params: {
      grant_type: 'refresh_token',
      refresh_token: token.refresh_token,
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
      refresh_token: token.refresh_token,
      client_id: application.uid
    }
    expect(response).to have_http_status(:bad_request)
    expect(JSON.parse(response.body)['error']).to eq('invalid_grant')
  end

  it 'rejects refresh when the AdminUser has been deleted (cascade)' do
    refresh = token.refresh_token
    admin.destroy
    post '/oauth/token', params: {
      grant_type: 'refresh_token',
      refresh_token: refresh,
      client_id: application.uid
    }
    expect(response).to have_http_status(:bad_request)
  end
end
