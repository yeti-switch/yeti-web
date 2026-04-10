# frozen_string_literal: true

module AdminUserOidcHandler
  extend ActiveSupport::Concern

  included do
    # :database_authenticatable is kept so Devise mounts the sessions
    # controller (/login route for the SSO button). Password login is
    # disabled via valid_password? below.
    devise :database_authenticatable, :omniauthable, :trackable, :ip_allowable,
           omniauth_providers: [:oidc]

    # REST API auth calls admin_user.authenticate(password) — alias it
    # so it returns false instead of raising NoMethodError.
    alias_method :authenticate, :valid_password?
  end

  # Always returns false — disables password auth in OIDC mode.
  def valid_password?(_password)
    false
  end
end
