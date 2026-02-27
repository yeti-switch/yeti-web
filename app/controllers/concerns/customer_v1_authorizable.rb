# frozen_string_literal: true

module CustomerV1Authorizable
  extend ActiveSupport::Concern

  CUSTOMER_AUTH_CLAIMS_AUDIENCE = CustomerV1Auth::Authenticator::AUDIENCE

  included do
    rescue_from CustomerV1Auth::Authorizer::AuthorizationError, with: :handle_authorization_error
    # @!method auth_context [CustomerV1Auth::AuthContext,nil]
    attr_reader :auth_context
  end

  def meta
    auth_meta = ApiLog::JwtAuthMetaBuilder.new(payload: jwt_payload_for_meta).call
    return if auth_meta.nil?

    { 'auth' => auth_meta }
  end

  private

  def authorize!
    source_context = build_source_context
    auth_context = CustomerV1Auth::Authorizer.authorize! source_context[:token]
    @auth_context = auth_context
    @response_cookie_needed = source_context[:from_cookie]
  end

  def setup_authorization_cookie
    return unless @response_cookie_needed
    return if auth_context.nil?

    auth_data = CustomerV1Auth::Authenticator.build_auth_data(auth_context)
    cookies[CustomerV1Auth::Authenticator::COOKIE_NAME] = {
      value: auth_data.token,
      expires: auth_data.expires_at,
      httponly: true
    }
  end

  def build_source_context
    header_token = request.headers['Authorization']&.split&.last
    if header_token.present?
      return {
        token: header_token,
        from_cookie: false
      }
    end

    {
      token: request.cookies[CustomerV1Auth::Authenticator::COOKIE_NAME],
      from_cookie: true
    }
  end

  def handle_authorization_error(error)
    logger.info "#{error.class}: #{error.message}"
    head 401
  end

  def jwt_payload_for_meta
    token = token_for_meta
    return if token.blank?

    verify_expiration = CustomerV1Auth::Authenticator::EXPIRATION_INTERVAL.present?
    CustomerV1Auth::TokenBuilder.decode(
      token,
      verify_expiration: verify_expiration,
      aud: CUSTOMER_AUTH_CLAIMS_AUDIENCE
    )
  end

  def token_for_meta
    return @auth_token if defined?(@auth_token) && @auth_token.present?

    header_token = request.headers['Authorization']&.split&.last
    return header_token if header_token.present?

    request.cookies[CustomerV1Auth::Authenticator::COOKIE_NAME]
  end
end
