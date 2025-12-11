# frozen_string_literal: true

class Api::Rest::Customer::V1::AuthController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :authenticate!, only: :create
  rescue_from CustomerV1Auth::Authenticator::AuthenticationError, with: :handle_authentication_error

  include CustomerV1Authorizable
  include Memoizable
  include WithPayloads
  before_action :authorize!, only: :show
  after_action :setup_authorization_cookie, only: :show

  define_memoizable :debug_mode, apply: -> { System::ApiLogConfig.exists?(controller: self.class.name) }

  def create
    if auth_params[:cookie_auth]
      cookies[CustomerV1Auth::Authenticator::COOKIE_NAME] = {
        value: @auth_token,
        expires: @expires_at,
        httponly: true
      }
      head 201
    else
      render json: { jwt: @auth_token }, status: 201
    end
  end

  def show
    render json: { 'allow-rec': auth_context.allow_listen_recording }
  end

  def destroy
    cookies[CustomerV1Auth::Authenticator::COOKIE_NAME] = {
      value: 'logout',
      expires: Time.parse('1970-01-01 00:00:00 UTC'),
      httponly: true
    }
    head 204
  end

  def meta
    nil
  end

  private

  def authenticate!
    result = CustomerV1Auth::Authenticator.authenticate!(
      auth_params[:login],
      auth_params[:password],
      remote_ip: remote_ip
    )
    @auth_token = result.token
    @expires_at = result.expires_at
  end

  def auth_params
    params.require(:auth).permit(:login, :password, :cookie_auth)
  end

  def remote_ip
    request.env['HTTP_X_REAL_IP'] || request.remote_ip
  end

  def handle_authentication_error(error)
    logger.info "#{error.class}: #{error.message}"
    jsonapi_error = JSONAPI::Exceptions::AuthenticationFailed.new
    render status: 401, json: { errors: jsonapi_error.errors.map(&:to_hash) }
  end

  def handle_authorization_error(error)
    logger.info "#{error.class}: #{error.message}"
    jsonapi_error = JSONAPI::Exceptions::AuthorizationFailed.new
    render status: 401, json: { errors: jsonapi_error.errors.map(&:to_hash) }
  end
end
