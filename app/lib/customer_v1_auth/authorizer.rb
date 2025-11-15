# frozen_string_literal: true

module CustomerV1Auth
  class Authorizer
    AuthorizationError = Class.new(StandardError)

    # @param token [String]
    # @return [CustomerV1Auth::AuthContext] when success
    # @raise [CustomerV1Auth::Authorizer::AuthenticationError] when failed
    def self.authorize!(token)
      instance = new(token)
      instance.authorize!
    end

    # @param token [String]
    def initialize(token)
      @token = token
    end

    # @return [CustomerV1Auth::AuthContext] when success
    # @raise [CustomerV1Auth::Authorizer::AuthenticationError] when failed
    def authorize!
      verify_expiration = Authenticator::EXPIRATION_INTERVAL.present?
      audience = Authenticator::AUDIENCE
      payload = TokenBuilder.decode(@token, verify_expiration: verify_expiration, aud: audience)
      raise AuthorizationError if payload.nil?

      api_access = System::ApiAccess.find_by(id: payload[:sub])
      raise AuthorizationError if api_access.nil?

      AuthContext.from_api_access(api_access)
    end
  end
end
