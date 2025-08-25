# frozen_string_literal: true

class Api::Rest::Customer::V1::CallAuthController < Api::Rest::Customer::V1::BaseController
  include CustomerV1Authorizable

  def create
    error_options = {
      status: '500',
      code: '500',
      title: 'Invalid request'
    }

    if current_customer.provision_gateway_id.nil?
      render status: 500, json: {
        errors: [error_options.merge(detail: 'Provisioning Gateway is not found.')]
      } and return
    end

    unless current_customer.provision_gateway.incoming_auth_allow_jwt?
      render status: 500, json: {
        errors: [error_options.merge(detail: 'Incoming JWT is disabled for Provisioning Gateway.')]
      } and return
    end

    private_key_path = YetiConfig&.api&.customer&.call_jwt_private_key
    raise 'Gateway Private key not found' if private_key_path.blank? || !File.exist?(private_key_path)

    private_key = OpenSSL::PKey::EC.new(File.read(private_key_path))
    lifetime = YetiConfig&.api&.customer&.call_jwt_lifetime.presence
    if private_key.blank?
      capture_error('Private key is not found.')
      render status: 500, json: { errors: [details: 'Internal Server Error'] } and return
    end

    now = Time.now.to_i
    payload = {
      gid: current_customer.provision_gateway.uuid,
      iat: now.to_i,
      exp: now + lifetime.to_i
    }

    token = JWT.encode(payload, private_key, JwtToken::ES256)
    render json: { jwt: token }, status: 201
  end
end
