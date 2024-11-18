# frozen_string_literal: true

module Authentication
  class AdminAuth
    EXPIRATION_INTERVAL = YetiConfig.api.token_lifetime.presence&.seconds&.freeze
    AUDIENCE = 'admin'
    AuthenticationError = Class.new(StandardError)
    IpAddressNotAllowedError = Class.new(AuthenticationError)
    Result = Data.define(:token)

    class << self
      # @param username [String]
      # @param password [String]
      # @param remote_ip [String]
      # @return [Authentication::AdminAuth::Result] when success
      # @raise [Authentication::AdminAuth::AuthenticationError] when failed caused by invalid username or password
      # @raise [Authentication::AdminAuth::IpAddressNotAllowedError] when failed caused by IP address not allowed
      def authenticate!(username, password, remote_ip:)
        instance = new(username, password, remote_ip: remote_ip)
        instance.authenticate!
      end

      # @param admin_user [AdminUser]
      # @param expires_at [Time,nil] overrides default expiration
      # @return [Authentication::CustomerV1Auth::Result]
      def build_auth_data(admin_user, expires_at: nil)
        expires_at ||= EXPIRATION_INTERVAL&.from_now
        payload = { sub: admin_user.id, aud: AUDIENCE }
        payload[:exp] = expires_at.to_i unless expires_at.nil?
        token = JwtToken.encode(payload)
        Result.new(token)
      end
    end

    # @param username [String]
    # @param password [String]
    # @param remote_ip [String]
    def initialize(username, password, remote_ip:)
      @username = username
      @password = password
      @remote_ip = remote_ip
    end

    # @return [Authentication::AdminAuth::Result] when success
    # @raise [Authentication::AdminAuth::AuthenticationError] when failed caused by invalid username or password
    # @raise [Authentication::AdminAuth::IpAddressNotAllowedError] when failed caused by IP address not allowed
    def authenticate!
      admin_user = AdminUser.find_by(username: @username)
      raise AuthenticationError if admin_user.nil?
      raise AuthenticationError unless admin_user.authenticate(@password)
      raise IpAddressNotAllowedError unless admin_user.ip_allowed?(@remote_ip)

      self.class.build_auth_data(admin_user)
    end
  end
end
