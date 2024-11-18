# frozen_string_literal: true

module Authorization
  class AdminAuth
    Result = Struct.new(:entity)
    AuthorizationError = Class.new(StandardError)

    class << self
      # @param token [String]
      # @param remote_ip [String]
      # @return [Authorization::AdminAuth::Result] when success
      # @raise [Authorization::AdminAuth::AuthenticationError] when failed
      def authorize!(token, remote_ip:)
        new(token, remote_ip:).authorize!
      end
    end

    # @param token [String]
    # @param remote_ip [String]
    def initialize(token, remote_ip:)
      @token = token
      @remote_ip = remote_ip
    end

    # @return [Authorization::AdminAuth::Result] when success
    # @raise [Authorization::AdminAuth::AuthenticationError] when failed
    def authorize!
      verify_expiration = Authentication::AdminAuth::EXPIRATION_INTERVAL.present?
      audience = Authentication::AdminAuth::AUDIENCE
      payload = JwtToken.decode(@token, verify_expiration: verify_expiration, aud: audience)
      raise AuthorizationError if payload.nil?

      admin_user = AdminUser.find_by(id: payload[:sub])
      raise AuthorizationError if admin_user.nil?
      raise AuthorizationError unless admin_user.ip_allowed?(@remote_ip)

      Result.new(admin_user)
    end
  end
end
