# frozen_string_literal: true

module Authorization
  class CustomerV1Auth
    Result = Struct.new(:entity)
    AuthorizationError = Class.new(StandardError)

    # @param token [String]
    # @return [Authorization::CustomerV1Auth::Result] when success
    # @raise [Authorization::CustomerV1Auth::AuthenticationError] when failed
    def self.authorize!(token)
      instance = new(token)
      instance.authorize!
    end

    # @param token [String]
    def initialize(token)
      @token = token
    end

    # @return [Authorization::CustomerV1Auth::Result] when success
    # @raise [Authorization::CustomerV1Auth::AuthenticationError] when failed
    def authorize!
      verify_expiration = Authentication::CustomerV1Auth::EXPIRATION_INTERVAL.present?
      audience = Authentication::CustomerV1Auth::AUDIENCE
      payload = JwtToken.decode(@token, verify_expiration: verify_expiration, aud: audience)
      raise AuthorizationError if payload.nil?

      entity = System::ApiAccess.find_by(id: payload[:sub])
      raise AuthorizationError if entity.nil?

      Result.new(entity)
    end
  end
end
