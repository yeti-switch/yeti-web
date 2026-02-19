# frozen_string_literal: true

module CustomerV1Auth
  class Authenticator
    EXPIRATION_INTERVAL = YetiConfig.api.customer.token_lifetime.presence&.seconds&.freeze
    AUDIENCE = 'customer-v1'
    COOKIE_NAME = '_yeti_customer_v1_session'
    DYNAMIC_SUB = 'D'
    Result = Struct.new(:token, :expires_at, :auth_context)
    AuthenticationError = Class.new(StandardError)

    # @param login [String]
    # @param password [String]
    # @param remote_ip [String]
    # @return [CustomerV1Auth::Authenticator::Result] when success
    # @raise [CustomerV1Auth::Authenticator::AuthenticationError] when failed
    def self.authenticate!(login, password, remote_ip:)
      instance = new(login, password, remote_ip: remote_ip)
      instance.authenticate!
    end

    # @param auth_context [CustomerV1Auth::AuthContext]
    # @return [CustomerV1Auth::Authenticator::Result]
    def self.build_auth_data(auth_context)
      expires_at = EXPIRATION_INTERVAL&.from_now
      token = build_token(auth_context, expires_at:)
      Result.new(token, expires_at, auth_context)
    end

    # @param auth_context [CustomerV1Auth::AuthContext]
    # @param expires_at [Time, nil]
    # @return [String] JWT token
    def self.build_token(auth_context, expires_at:)
      payload = if auth_context.api_access_id.nil?
                  { aud: AUDIENCE, sub: DYNAMIC_SUB, cfg: auth_context.to_config }
                else
                  { aud: AUDIENCE, sub: auth_context.api_access_id }
                end
      payload[:exp] = expires_at.to_i unless expires_at.nil?
      TokenBuilder.encode(payload)
    end

    # @param login [String]
    # @param password [String]
    # @param remote_ip [String]
    def initialize(login, password, remote_ip:)
      @login = login
      @password = password
      @remote_ip = remote_ip
    end

    # @return [CustomerV1Auth::Authenticator::Result] when success
    # @raise [CustomerV1Auth::Authenticator::AuthenticationError] when failed
    def authenticate!
      api_access = System::ApiAccess.find_by(login: @login)
      raise AuthenticationError, 'login not exist' if api_access.nil?
      raise AuthenticationError, 'password not match' unless api_access.authenticate(@password)
      raise AuthenticationError, 'remote_ip not match' unless api_access.authenticate_ip(@remote_ip)

      auth_context = AuthContext.from_api_access(api_access)
      self.class.build_auth_data(auth_context)
    end
  end
end
