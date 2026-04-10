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

    # Keep web password sign-in disabled while preserving the legacy
    # password-backed admin JWT API authentication path.
    define_method(:authenticate) do |password|
      Devise::Encryptor.compare(self.class, encrypted_password, password)
    end
  end
end
