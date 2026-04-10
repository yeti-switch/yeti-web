# frozen_string_literal: true

module AdminUserOidcHandler
  extend ActiveSupport::Concern

  included do
    # :database_authenticatable is kept so Devise mounts the sessions
    # controller (/login route for the SSO button). Password login is
    # disabled via valid_password? override below.
    devise :database_authenticatable, :omniauthable, :trackable, :ip_allowable,
           omniauth_providers: [:oidc]

    # Override must be defined AFTER the devise() call because
    # :database_authenticatable includes Devise::Models::DatabaseAuthenticatable
    # which would shadow a method defined earlier in the ancestor chain.
    define_method(:valid_password?) { |_password| false }

    # REST API auth calls admin_user.authenticate(password) — alias it
    # so it returns false instead of raising NoMethodError.
    alias_method :authenticate, :valid_password?
  end
end
