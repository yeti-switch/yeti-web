# frozen_string_literal: true

# Configuration always happens, even when the feature is off: the gem prepends
# an `openid_request` association onto every Doorkeeper access grant model, and
# that association reads Doorkeeper::OpenidConnect.configuration while the class
# body is evaluated — so an unconfigured gem makes OauthAccessGrant raise
# MissingConfiguration at eager load, in every deployment, whether or not OAuth
# is enabled. oauth.oidc.enabled decides only whether the OIDC surface is
# exposed: the `openid` scope (doorkeeper.rb) and the discovery / JWKS /
# userinfo routes (routes.rb).
oidc_enabled = YetiConfig.oauth&.enabled && YetiConfig.oauth.oidc&.enabled
oidc_issuer = nil
oidc_signing_key = nil

if oidc_enabled
  oidc_issuer = YetiConfig.oauth.issuer.presence
  if oidc_issuer.nil?
    raise 'yeti_web.yml: oauth.issuer is required when oauth.oidc.enabled. ' \
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

  open_id_request_class 'OauthOpenidRequest'

  # `sub` identifies the user forever and must never be recycled. The primary
  # key qualifies; the email does not — an admin who changes address would come
  # back to every client as a different person.
  subject { |resource_owner, _application| resource_owner.id.to_s }

  # Filtering on enabled here is what stops a disabled admin's still-valid
  # access token from resolving at the userinfo endpoint.
  resource_owner_from_access_token do |access_token|
    AdminUser.find_by(id: access_token.resource_owner_id, enabled: true)
  end

  auth_time_from_resource_owner(&:current_sign_in_at)

  reauthenticate_resource_owner do |_resource_owner, return_to|
    store_location_for :admin_user, return_to
    sign_out :admin_user
    redirect_to new_admin_user_session_url
  end

  claims do
    # `response:` defaults to [:user_info] alone, so a client that reads the
    # id_token and never calls /oauth/userinfo would otherwise get a token
    # carrying nothing but `sub`. Every claim is declared for both.
    claim(:name, response: %i[id_token user_info]) { |resource_owner, _scopes| resource_owner.display_name }
    claim(:preferred_username, response: %i[id_token user_info]) { |resource_owner, _scopes| resource_owner.username }

    # AdminUser#email is not a column — it is read off the billing contact, so
    # it is nil for any admin who has none.
    claim(:email, response: %i[id_token user_info]) { |resource_owner, _scopes| resource_owner.email }
    claim(:email_verified, response: %i[id_token user_info]) { |resource_owner, _scopes| resource_owner.email.present? }

    # Tied to `openid` rather than the default scope for a non-standard claim
    # name, which would be `profile` — a client requesting `openid` alone would
    # then silently lose its only means of authorising anyone.
    claim(:groups, response: %i[id_token user_info], scope: :openid) { |resource_owner, _scopes| resource_owner.roles }
  end
end
