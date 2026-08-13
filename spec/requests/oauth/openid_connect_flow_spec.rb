# frozen_string_literal: true

RSpec.describe 'OIDC authorization code flow', type: :request do
  include_context :with_oauth_routes

  # :filled gives the admin a billing contact, which is where AdminUser#email
  # comes from — without one the email claim is legitimately nil.
  let(:admin) { create(:admin_user, :filled, roles: %w[admin noc]) }
  let(:application) do
    create_oauth_application(
      name: 'stats-client',
      confidential: true,
      scopes: 'openid profile email',
      redirect_uri: 'https://stats.example.com/api/auth/callback'
    )
  end
  let(:code_verifier) { SecureRandom.urlsafe_base64(64) }
  let(:code_challenge) { Base64.urlsafe_encode64(Digest::SHA256.digest(code_verifier), padding: false) }
  let(:nonce) { SecureRandom.urlsafe_base64(16) }

  # Shortcut for the specs below, which are about the token exchange rather than
  # consent: the grant is issued directly, and the nonce row is what
  # Doorkeeper::OpenidConnect::OAuth::Authorization::Code would have written.
  # The consent screen itself is driven for real in the context further down.
  def create_authorization_code(scopes: 'openid profile email', with_nonce: true)
    grant = OauthAccessGrant.create!(
      application: application,
      resource_owner_id: admin.id,
      expires_in: 600,
      redirect_uri: application.redirect_uri,
      scopes: scopes,
      code_challenge: code_challenge,
      code_challenge_method: 'S256'
    )
    OauthOpenidRequest.create!(access_grant: grant, nonce: nonce) if with_nonce
    grant.plaintext_token
  end

  def exchange(code)
    post '/oauth/token', params: {
      grant_type: 'authorization_code',
      code: code,
      client_id: application.uid,
      client_secret: application.plaintext_secret,
      redirect_uri: application.redirect_uri,
      code_verifier: code_verifier
    }
    JSON.parse(response.body)
  end

  # Verifies the signature the way a client does: against the published JWKS,
  # not against the private key we happen to have on disk.
  def decode_id_token(id_token)
    get '/oauth/discovery/keys'
    jwk = JWT::JWK.import(JSON.parse(response.body)['keys'].first)
    JWT.decode(id_token, jwk.verify_key, true, algorithm: 'RS256').first
  end

  context 'when the openid scope was granted' do
    # let!, not let: the assertions below read `response`, which only exists
    # once the exchange has actually been POSTed.
    let!(:token_response) { exchange(create_authorization_code) }
    let(:claims) { decode_id_token(token_response['id_token']) }

    it 'returns an id_token alongside the access token' do
      expect(response).to have_http_status(:success)
      expect(token_response['access_token']).to be_present
      expect(token_response['id_token']).to be_present
    end

    it 'signs the id_token with the published key and binds it to this client' do
      expect(claims['iss']).to eq(YetiConfig.oauth.issuer)
      expect(claims['aud']).to eq(application.uid)
      # Replay protection: the client checks this against what it sent.
      expect(claims['nonce']).to eq(nonce)
      expect(claims['exp']).to be > claims['iat'] - 1
    end

    it 'identifies the admin by a stable subject' do
      expect(claims['sub']).to eq(admin.id.to_s)
    end

    # In the id_token only because every claim declares response: both. The gem
    # defaults to user_info alone, which leaves a client that never calls
    # /oauth/userinfo with a token carrying nothing but sub.
    it 'carries the profile claims in the id_token itself' do
      expect(claims['name']).to eq(admin.username)
      expect(claims['preferred_username']).to eq(admin.username)
      expect(claims['email']).to eq(admin.email)
      expect(claims['email_verified']).to be(true)
    end

    # The authorisation boundary: clients filter on this.
    it 'carries the admin roles as the groups claim' do
      expect(claims['groups']).to match_array(%w[admin noc])
    end
  end

  # Regression: Doorkeeper's stock consent view resubmits every pre-auth
  # parameter except the nonce, so the first authorization for a client — the
  # only one that renders this screen, since afterwards can_authorize_response?
  # skips it — wrote no OauthOpenidRequest row and produced a nonce-less
  # id_token that every client rejects as a nonce mismatch. Fixed by
  # app/views/doorkeeper/authorizations/new.html.erb.
  context 'POST /oauth/authorize (first authorization, consent screen)' do
    include_context :login_as_admin

    # Drives consent the way a browser does: render the screen, then submit
    # exactly the fields the form carries. That is the point of the test — the
    # bug was a missing field, so anything that builds the params by hand would
    # pass against the broken view. The authenticity_token comes along with the
    # rest because the test env keeps allow_forgery_protection on (same
    # approach as spec/requests/invoice_template_playground_spec.rb).
    def consent_form_fields
      get '/oauth/authorize', params: {
        response_type: 'code',
        client_id: application.uid,
        redirect_uri: application.redirect_uri,
        scope: 'openid profile email',
        code_challenge: code_challenge,
        code_challenge_method: 'S256',
        state: 'xyz',
        nonce: nonce
      }
      expect(response).to have_http_status(:success)

      # The page holds two forms posting to the same URL; the deny one is a
      # DELETE tunnelled through _method, so pick by that rather than by
      # position.
      authorize_form = Nokogiri::HTML(response.body).css('form').find do |form|
        form.at_css('input[name="_method"][value="delete"]').nil?
      end
      expect(authorize_form).to be_present

      authorize_form.css('input[type="hidden"]').to_h { |input| [input['name'], input['value']] }
    end

    it 'carries the nonce through consent and onto the issued grant' do
      fields = consent_form_fields
      expect(fields['nonce']).to eq(nonce)

      post '/oauth/authorize', params: fields

      expect(response).to have_http_status(:redirect)
      expect(response.location).to start_with(application.redirect_uri)

      # Identified by the code we were just handed, not by the newest row —
      # hash_token_secrets is on, so by_token does the digest lookup for us.
      issued_code = Rack::Utils.parse_nested_query(URI.parse(response.location).query)['code']
      grant = OauthAccessGrant.by_token(issued_code)
      expect(grant).to be_present
      expect(OauthOpenidRequest.find_by(access_grant: grant)&.nonce).to eq(nonce)
    end
  end

  context 'without the openid scope' do
    it 'issues a plain OAuth token and no id_token' do
      body = exchange(create_authorization_code(scopes: 'mcp', with_nonce: false))
      expect(response).to have_http_status(:success)
      expect(body['access_token']).to be_present
      expect(body).not_to have_key('id_token')
    end
  end

  context 'when no nonce was sent' do
    it 'still issues an id_token, without a nonce claim' do
      body = exchange(create_authorization_code(with_nonce: false))
      expect(response).to have_http_status(:success)
      expect(decode_id_token(body['id_token'])).not_to have_key('nonce')
    end
  end

  context 'when the admin is disabled' do
    it 'refuses the exchange, so no id_token is minted' do
      code = create_authorization_code
      admin.update!(enabled: false)
      body = exchange(code)
      expect(response).to have_http_status(:bad_request)
      expect(body['error']).to eq('invalid_grant')
    end
  end
end
