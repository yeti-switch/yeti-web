# frozen_string_literal: true

class Api::Rest::Admin::AuthController < ApplicationController
  skip_before_action :verify_authenticity_token

  include Memoizable
  include WithPayloads

  rescue_from Authentication::AdminAuth::AuthenticationError, with: :handle_authentication_error
  rescue_from Authentication::AdminAuth::IpAddressNotAllowedError, with: :handle_ip_not_allowed

  define_memoizable :debug_mode, apply: -> { System::ApiLogConfig.exists?(controller: self.class.name) }

  before_action :authenticate

  def create
    render json: { jwt: @auth_token }, status: 201
  end

  def meta
    nil
  end

  private

  def authenticate
    result = Authentication::AdminAuth.authenticate!(
      auth_params[:username],
      auth_params[:password],
      remote_ip: request.remote_ip
    )
    @auth_token = result.token
  end

  def auth_params
    params.require(:auth).permit(:username, :password)
  end

  def handle_authentication_error
    error = JSONAPI::Exceptions::AuthenticationFailed.new
    render status: 401, json: { errors: error.errors.map(&:to_hash) }
  end

  def handle_ip_not_allowed
    error = JSONAPI::Exceptions::AuthenticationFailed.new(
      detail: 'Your IP address is not allowed.'
    )
    render status: 401, json: { errors: error.errors.map(&:to_hash) }
  end
end
