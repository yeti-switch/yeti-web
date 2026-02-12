# frozen_string_literal: true

module AdminApiAuthorizable
  extend ActiveSupport::Concern

  ADMIN_AUTH_CLAIMS_AUDIENCE = Authentication::AdminAuth::AUDIENCE

  included do
    rescue_from Authorization::AdminAuth::AuthorizationError, with: :handle_authorization_error

    before_action :authorize
    attr_reader :current_admin_user
  end

  def context
    { current_admin_user: current_admin_user }
  end

  def capture_user
    return if current_admin_user.nil?

    {
      id: current_admin_user.id,
      username: current_admin_user.username,
      class: 'AdminUser',
      ip_address: '{{auto}}'
    }
  end

  def meta
    auth_meta = ApiLog::JwtAuthMetaBuilder.new(payload: jwt_payload_for_meta).call
    return if auth_meta.nil?

    { 'auth' => auth_meta }
  end

  private

  def authorize
    @auth_token = params[:token] || request.headers['Authorization']&.split&.last
    result = Authorization::AdminAuth.authorize!(@auth_token, remote_ip: request.remote_ip)
    @current_admin_user = result.entity
  end

  def handle_authorization_error
    head 401
  end

  def jwt_payload_for_meta
    return if @auth_token.blank?

    verify_expiration = Authentication::AdminAuth::EXPIRATION_INTERVAL.present?
    JwtToken.decode(
      @auth_token,
      verify_expiration: verify_expiration,
      aud: ADMIN_AUTH_CLAIMS_AUDIENCE
    )
  end
end
