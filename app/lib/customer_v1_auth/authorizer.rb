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
      raise AuthorizationError, 'token decode failed' if payload.nil?

      if payload[:sub] == Authenticator::DYNAMIC_SUB
        auth_context = AuthContext.from_config(payload[:cfg])
        raise AuthorizationError, 'customer not exist' if auth_context.customer.nil?
        if auth_context.customer_portal_access_profile.nil?
          raise AuthorizationError, 'customer_portal_access_profile not exist'
        end

        return auth_context
      end

      api_access = System::ApiAccess.find_by(id: payload[:sub])
      raise AuthorizationError, 'api_access not exist' if api_access.nil?

      AuthContext.from_api_access(api_access)
    end
  end
end
