# frozen_string_literal: true

# Helpers for OIDC feature/request specs. Uses OmniAuth test mode to
# short-circuit the full discovery/JWKS/token/userinfo round-trip, which
# keeps the specs focused on the gem's callback → on_login → AdminUser
# behaviour rather than the OpenID Connect protocol itself (already covered
# by omniauth_openid_connect's own suite).
module OidcStubs
  DEFAULT_CLAIMS = {
    'preferred_username' => 'alice',
    'email' => 'alice@test',
    'roles' => ['admin']
  }.freeze

  def stub_oidc_sign_in(sub: 'alice-sub', claims: {})
    merged = DEFAULT_CLAIMS.merge(claims.transform_keys(&:to_s))
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:oidc] = OmniAuth::AuthHash.new(
      provider: 'oidc',
      uid: sub,
      info: {
        email: merged['email'],
        name: merged['name'],
        nickname: merged['preferred_username']
      },
      credentials: {},
      extra: { raw_info: merged.merge('sub' => sub) }
    )
  end

  def stub_oidc_failure(message_key = :invalid_credentials)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:oidc] = message_key
  end

  def reset_oidc_stubs
    OmniAuth.config.mock_auth[:oidc] = nil
    OmniAuth.config.test_mode = false
  end
end

RSpec.configure do |config|
  config.include OidcStubs, oidc_mode: true

  config.after(:each, :oidc_mode) { reset_oidc_stubs }
end
