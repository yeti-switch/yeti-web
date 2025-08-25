# frozen_string_literal: true

class Api::Rest::Customer::V1::CallAuthController < Api::Rest::Customer::V1::BaseController
  skip_before_action :verify_authenticity_token
  include CustomerV1Authorizable

  rescue_from Authentication::CustomerV1Auth::AuthenticationError, with: :handle_authentication_error

  def create
    error_options = {
      status: '401',
      code: '401',
      title: 'Invalid request'
    }
    auth_context = CustomerV1Authorizable.build_auth_context(request)
    result = Authorization::CustomerV1Auth.authorize! auth_context[:token]
    raise Authentication::CustomerV1Auth::AuthenticationError if result.entity.nil?
    render status: 401, json: { errors: [error_options.merge(detail: 'Provisioning Gateway is not found.')] } and return if result.entity.provision_gateway_id.nil?
    render status: 401, json: { errors: [error_options.merge(detail: 'Incoming JWT is disabled for Provisioning Gateway.')] } and return unless result.entity.provision_gateway.incoming_auth_allow_jwt?

    private_key = OpenSSL::PKey::EC.new(File.read('config/private.key'))
    lifetime = YetiConfig&.api&.customer&.call_jwt_lifetime.presence
    if private_key.blank?
      capture_error('Private key is not found.')
      render status: 500, json: { errors: [details: 'Internal Server Error'] } and return
    end

    now = Time.now.to_i
    payload = {
      gid: result.entity.provision_gateway.uuid,
      iat: now.to_i,
      exp: now + lifetime.to_i
    }

    token = JWT.encode(payload, private_key, 'ES256')
    render json: { jwt: token }, status: 201
  end

  def auth_params
    params.require(:auth).permit(:login, :password, :cookie_auth)
  end

  def handle_authentication_error
    error = JSONAPI::Exceptions::AuthenticationFailed.new
    render status: 401, json: { errors: error.errors.map(&:to_hash) }
  end

  def handle_authorization_error
    error = JSONAPI::Exceptions::AuthorizationFailed.new
    render status: 401, json: { errors: error.errors.map(&:to_hash) }
  end
end
