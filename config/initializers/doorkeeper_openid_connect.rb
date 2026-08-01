# frozen_string_literal: true

# OpenID Connect layer on top of the Doorkeeper OAuth provider configured in
# doorkeeper.rb (which must run first — this file's name sorts after it, and
# Doorkeeper::OpenidConnect.configure reads Doorkeeper's ORM setting).
#
# OAuth 2 answers "may this client call the API?"; OIDC answers "who is the
# user?". Enabling this makes admin_users the login for other yeti components —
# yeti-statistics, Grafana, anything that speaks OIDC — by issuing a signed
# id_token alongside the access token.
#
# Unlike doorkeeper.rb, this block is NOT skipped when the feature is off. The
# gem prepends an `openid_request` association onto every Doorkeeper access
# grant model, and that association reads
# Doorkeeper::OpenidConnect.configuration while the class body is evaluated —
# so an unconfigured gem makes OauthAccessGrant raise MissingConfiguration the
# moment anything loads it, which in production means at eager load, in every
# deployment, whether or not OAuth is even enabled.
#
# So configuration always happens, and oauth.oidc.enabled decides only whether
# the OIDC surface is exposed: the `openid` scope (doorkeeper.rb) and the
# discovery / JWKS / userinfo routes (routes.rb). With no `openid` scope on
# offer, no client can be granted one, no id_token is ever minted, and the
# signing key below is never read — which is why it may be absent when the
# feature is off.
oidc_enabled = YetiConfig.oauth&.enabled && YetiConfig.oauth.oidc&.enabled
oidc_issuer = nil
oidc_signing_key = nil

if oidc_enabled
  oidc_issuer = YetiConfig.oauth.oidc.issuer.presence
  if oidc_issuer.nil?
    raise 'yeti_web.yml: oauth.oidc.issuer is required when oauth.oidc.enabled. ' \
          'It must equal, byte for byte, the issuer configured on every client — ' \
          'clients compare it against the discovery document and the id_token, ' \
          'and a trailing slash is enough to break every login.'
  end

  key_path = YetiConfig.oauth.oidc.signing_key_path.presence
  if key_path.nil?
    raise 'yeti_web.yml: oauth.oidc.signing_key_path is required when oauth.oidc.enabled. ' \
          'Generate one with: bundle exec rake oauth:oidc:generate_signing_key[/etc/yeti-web/oidc_signing_key.pem]'
  end

  key_path = Rails.root.join(key_path) unless Pathname.new(key_path).absolute?
  unless File.readable?(key_path)
    raise "yeti_web.yml: oauth.oidc.signing_key_path #{key_path} is missing or unreadable. " \
          "Generate one with: bundle exec rake oauth:oidc:generate_signing_key[#{key_path}]"
  end
  oidc_signing_key = File.read(key_path)
end

Doorkeeper::OpenidConnect.configure do
  issuer oidc_issuer
  signing_key oidc_signing_key
  signing_algorithm :rs256
  subject_types_supported [:public]

  # Custom model so the table lives in the gui schema, like the other
  # Doorkeeper tables. See app/models/oauth_openid_request.rb.
  open_id_request_class 'OauthOpenidRequest'

  # `sub` identifies the user forever and must never be recycled. The primary
  # key qualifies; the email does not — an admin who changes address would
  # come back to every client as a different person.
  subject { |resource_owner, _application| resource_owner.id.to_s }

  # Filtering on enabled here is what stops a disabled admin's still-valid
  # access token from resolving at the userinfo endpoint. Token issuance is
  # blocked separately by the before_successful_strategy_response hook in
  # doorkeeper.rb.
  resource_owner_from_access_token do |access_token|
    AdminUser.find_by(id: access_token.resource_owner_id, enabled: true)
  end

  auth_time_from_resource_owner(&:current_sign_in_at)

  # Honours prompt=login: drop the Devise session and send the admin back
  # through the normal sign-in page, then on to where they were going.
  reauthenticate_resource_owner do |_resource_owner, return_to|
    store_location_for :admin_user, return_to
    sign_out :admin_user
    redirect_to new_admin_user_session_url
  end

  # Claim generators are called with (resource_owner, scopes, access_token).
  #
  # `response:` decides which document a claim appears in, and it defaults to
  # [:user_info] alone. Clients that read the id_token and never call
  # /oauth/userinfo — the common case, and what yeti-statistics does — would
  # otherwise get a token carrying nothing but `sub`, sign the user in as
  # anonymous, and then fail whatever group check they run. So every claim is
  # declared for both.
  claims do
    claim(:name, response: %i[id_token user_info]) { |resource_owner, _scopes| resource_owner.display_name }
    claim(:preferred_username, response: %i[id_token user_info]) { |resource_owner, _scopes| resource_owner.username }

    # AdminUser#email is not a column — it is read off the billing contact, so
    # it is nil for any admin who has none. Emitting nil is the honest answer;
    # clients that need an address fall back to `preferred_username`, which is
    # the username and always present.
    claim(:email, response: %i[id_token user_info]) { |resource_owner, _scopes| resource_owner.email }
    # Set by another admin on the billing contact, never self-asserted — so an
    # address that exists is as verified as this provider can make it.
    claim(:email_verified, response: %i[id_token user_info]) { |resource_owner, _scopes| resource_owner.email.present? }

    # The authorisation boundary. Clients match their own allowlist against
    # this (yeti-statistics' `allowed_groups`); without it they fall back to
    # "anyone this provider knows", which here means every enabled admin can
    # read every customer's traffic and margin.
    #
    # Tied to `openid` rather than the default scope for a non-standard claim
    # name, which would be `profile` — a client requesting `openid` alone would
    # then silently lose its only means of authorising anyone.
    claim(:groups, response: %i[id_token user_info], scope: :openid) { |resource_owner, _scopes| resource_owner.roles }
  end
end
