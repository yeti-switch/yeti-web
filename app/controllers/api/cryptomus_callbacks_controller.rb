# frozen_string_literal: true

class Api::CryptomusCallbacksController < ActionController::API
  include CaptureError::ControllerMethods
  include WithPayloads
  include Memoizable

  rescue_from StandardError, with: :server_error

  define_memoizable :debug_mode, apply: -> { System::ApiLogConfig.exists?(controller: self.class.name) }

  # https://doc.cryptomus.com/payments/webhook
  def create
    payload = params.except(:controller, :action, :sign, :cryptomus_callback).to_unsafe_h.to_h
    sign = params[:sign]

    unless Cryptomus::WebhookValidator.validate(payload:, sign:)
      Rails.logger.info { 'invalid signature' }
      head 400
      return
    end

    payload.deep_symbolize_keys!
    CryptomusPayment::HandleWebhook.call(payload:)

    head 200
  end

  def meta
    nil
  end

  private

  def server_error(error)
    log_error(error)
    capture_error(error)
    head 500
  end

  def capture_extra
    { params: params.to_unsafe_h }
  end
end
