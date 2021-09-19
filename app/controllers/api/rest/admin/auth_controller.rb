# frozen_string_literal: true

class Api::Rest::Admin::AuthController < Knock::AuthTokenController
  private

  def entity_name
    'AdminUser'
  end

  def auth_params
    params.require(:auth).permit :username, :password
  end

  def not_found
    error = JSONAPI::Exceptions::AuthenticationFailed.new
    render status: :unauthorized, json: { errors: error.errors.map(&:to_hash) }
  end

  def ip_not_allowed
    error = JSONAPI::Exceptions::AuthenticationFailed.new(
      detail: 'Your IP address is not allowed.'
    )
    render status: :unauthorized, json: { errors: error.errors.map(&:to_hash) }
  end

  def authenticate
    super

    ip_not_allowed unless entity.ip_allowed?(request.remote_ip)
  end
end
