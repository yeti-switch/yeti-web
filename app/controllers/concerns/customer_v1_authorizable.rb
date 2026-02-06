# frozen_string_literal: true

module CustomerV1Authorizable
  extend ActiveSupport::Concern

  included do
    rescue_from CustomerV1Auth::Authorizer::AuthorizationError, with: :handle_authorization_error
    # @!method auth_context [CustomerV1Auth::AuthContext,nil]
    attr_reader :auth_context
  end

  def meta
    build_auth_context_meta
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

  def build_auth_context_meta
    return if auth_context.nil?

    {
      'customer_id' => auth_context.customer_id,
      'account_ids' => auth_context.account_ids,
      'api_access_id' => auth_context.api_access_id,
      'login' => auth_context.login,
      'customer_portal_access_profile_id' => auth_context.customer_portal_access_profile_id,
      'allow_listen_recording' => auth_context.allow_listen_recording,
      'allow_outgoing_numberlists_ids' => auth_context.allow_outgoing_numberlists_ids
    }
  end
end
