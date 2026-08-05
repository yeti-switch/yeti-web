# frozen_string_literal: true

RSpec.describe 'OIDC userinfo', type: :request do
  include_context :with_oauth_routes

  let(:admin) { create(:admin_user, :filled, roles: %w[admin]) }
  let(:application) { create_oauth_application(confidential: true, scopes: 'openid profile email') }
  let(:token) { issue_access_token(admin: admin, application: application, scopes: 'openid profile email') }

  subject do
    get '/oauth/userinfo', headers: { 'Authorization' => "Bearer #{token.plaintext_token}" }
  end

  it 'returns the same claims as the id_token' do
    subject
    expect(response).to have_http_status(:success)
    payload = JSON.parse(response.body)
    expect(payload['sub']).to eq(admin.id.to_s)
    expect(payload['name']).to eq(admin.username)
    expect(payload['preferred_username']).to eq(admin.username)
    expect(payload['email']).to eq(admin.email)
    expect(payload['groups']).to match_array(%w[admin])
  end

  # Only `groups` declares `scope:`; the gem derives the rest from
  # Claims::Claim::STANDARD_CLAIMS. That default carries a privacy guarantee, so
  # pin it rather than trust it to survive a gem upgrade.
  context 'with a token granted openid alone' do
    let(:token) { issue_access_token(admin: admin, application: application, scopes: 'openid') }

    it 'returns only the claims that scope covers' do
      subject
      expect(response).to have_http_status(:success)
      payload = JSON.parse(response.body)

      expect(payload['sub']).to eq(admin.id.to_s)
      # Carried by openid on purpose: it is what a client authorises against.
      expect(payload['groups']).to match_array(%w[admin])

      expect(payload).not_to have_key('name')
      expect(payload).not_to have_key('preferred_username')
      expect(payload).not_to have_key('email')
      expect(payload).not_to have_key('email_verified')
    end
  end

  it 'rejects a token whose admin has been disabled' do
    token
    admin.update!(enabled: false)
    subject
    # resource_owner_from_access_token filters on enabled, so the owner no
    # longer resolves and the gem cannot build a response.
    expect(response).not_to have_http_status(:success)
  end

  it 'rejects an unauthenticated request' do
    get '/oauth/userinfo'
    expect(response).to have_http_status(:unauthorized)
  end
end
