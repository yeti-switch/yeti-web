# frozen_string_literal: true

module CustomerV1Authorizable
  extend ActiveSupport::Concern

  included do
    rescue_from Authorization::CustomerV1Auth::AuthorizationError, with: :handle_authorization_error
    attr_reader :current_customer
  end

  private

  def authorize!
    auth_context = build_auth_context
    result = Authorization::CustomerV1Auth.authorize! auth_context[:token]
    @current_customer = result.entity
    @response_cookie_needed = auth_context[:from_cookie]
  end

  def setup_authorization_cookie
    return unless @response_cookie_needed
    return if current_customer.nil?

    auth_data = Authentication::CustomerV1Auth.build_auth_data(current_customer)
    cookies[Authentication::CustomerV1Auth::COOKIE_NAME] = {
      value: auth_data.token,
      expires: auth_data.expires_at,
      httponly: true
    }
  end

  def build_auth_context
    header_token = request.headers['Authorization']&.split&.last
    if header_token.present?
      return {
        token: header_token,
        from_cookie: false
      }
    end

    {
      token: request.cookies[Authentication::CustomerV1Auth::COOKIE_NAME],
      from_cookie: true
    }
  end

  def handle_authorization_error
    head 401
  end
end
