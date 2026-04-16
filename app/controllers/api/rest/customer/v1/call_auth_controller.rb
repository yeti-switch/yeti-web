# frozen_string_literal: true

class Api::Rest::Customer::V1::CallAuthController < Api::Rest::Customer::V1::BaseController
  include CustomerV1Authorizable

  ConfigurationError = Class.new(JSONAPI::Exceptions::Error) do
    def initialize(detail)
      @detail = detail
      super()
    end

    def errors
      [create_error_object(
        code: JSONAPI::INTERNAL_SERVER_ERROR,
        status: :internal_server_error,
        title: 'Internal Server Error',
        detail: @detail
      )]
    end
  end

  def create
    if auth_context.provision_gateway_id.nil?
      raise ConfigurationError, 'Provisioning Gateway is not found.'
    end

    unless auth_context.provision_gateway.incoming_auth_allow_jwt?
      raise ConfigurationError, 'Incoming JWT is disabled for Provisioning Gateway.'
    end

    private_key_path = YetiConfig&.api&.customer&.call_jwt_private_key
    if private_key_path.blank? || !File.exist?(private_key_path)
      raise ConfigurationError, 'Gateway Private key not found.'
    end

    private_key = OpenSSL::PKey::EC.new(File.read(private_key_path))
    lifetime = YetiConfig&.api&.customer&.call_jwt_lifetime.presence
    if private_key.blank?
      raise ConfigurationError, 'Private key is not found.'
    end

    now = Time.now.to_i
    payload = {
      gid: auth_context.provision_gateway.uuid,
      iat: now.to_i,
      exp: now + lifetime.to_i
    }

    token = JWT.encode(payload, private_key, JwtToken::ES256)
    render json: { jwt: token }, status: 201
  rescue StandardError => e
    handle_exceptions(e)
  end
end
