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
