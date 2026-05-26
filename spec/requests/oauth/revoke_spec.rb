# frozen_string_literal: true

RSpec.describe 'OAuth token revocation', type: :request do
  include_context :with_oauth_routes

  let(:admin) { create(:admin_user) }
  let(:application) { create_oauth_application(confidential: false) }
  let(:token) { issue_access_token(admin: admin, application: application) }

  it 'revokes the access token and subsequent MCP calls are rejected' do
    raw_token = token.token

    post '/oauth/revoke', params: {
      token: raw_token,
      client_id: application.uid
    }
    expect(response).to have_http_status(:success)
    expect(token.reload.revoked_at).to be_present

    mcp_call(token: raw_token, method: 'tools/list')
    expect(response).to have_http_status(:unauthorized)
  end
end
