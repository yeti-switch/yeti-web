# frozen_string_literal: true

module AdminApiAuthorizable
  extend ActiveSupport::Concern

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

  private

  def authorize
    auth_token = params[:token] || request.headers['Authorization']&.split&.last
    result = Authorization::AdminAuth.authorize!(auth_token, remote_ip: request.remote_ip)
    @current_admin_user = result.entity
  end

  def handle_authorization_error
    head 401
  end
end
