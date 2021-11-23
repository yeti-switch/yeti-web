# frozen_string_literal: true

module Authentication
  class CustomerV1Auth
    EXPIRATION_INTERVAL = Rails.configuration.yeti_web['api']['token_lifetime'].presence&.seconds&.freeze
    AUDIENCE = 'customer-v1'
    COOKIE_NAME = '_yeti_customer_v1_session'
    Result = Struct.new(:token, :expires_at)
    AuthenticationError = Class.new(StandardError)

    # @param login [String]
    # @param password [String]
    # @param remote_ip [String]
    # @return [Authentication::CustomerV1Auth::Result] when success
    # @raise [Authentication::CustomerV1Auth::AuthenticationError] when failed
    def self.authenticate!(login, password, remote_ip:)
      instance = new(login, password, remote_ip: remote_ip)
      instance.authenticate!
    end

    # @param entity [System::ApiAccess]
    # @return [Authentication::CustomerV1Auth::Result]
    def self.build_auth_data(entity)
      expires_at = EXPIRATION_INTERVAL&.from_now
      payload = { sub: entity.id, aud: AUDIENCE }
      payload[:exp] = expires_at.to_i unless expires_at.nil?
      token = JwtToken.encode(payload)
      Result.new(token, expires_at)
    end

    # @param login [String]
    # @param password [String]
    # @param remote_ip [String]
    def initialize(login, password, remote_ip:)
      @login = login
      @password = password
      @remote_ip = remote_ip
    end

    # @return [Authentication::CustomerV1Auth::Result] when success
    # @raise [Authentication::CustomerV1Auth::AuthenticationError] when failed
    def authenticate!
      entity = System::ApiAccess.find_by(login: @login)
      raise AuthenticationError if entity.nil?
      raise AuthenticationError unless entity.authenticate(@password)
      raise AuthenticationError unless entity.authenticate_ip(@remote_ip)

      self.class.build_auth_data(entity)
    end
  end
end
