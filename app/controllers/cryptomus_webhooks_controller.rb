# frozen_string_literal: true

class CryptomusWebhooksController < ActionController::API
  include CaptureError::ControllerMethods

  rescue_from StandardError, with: :handle_exceptions
  rescue_from ActiveRecord::RecordNotFound, with: :handle_exceptions

  # https://doc.cryptomus.com/payments/webhook
  def create
    payload = params.except(:controller, :action, :sign, :cryptomus_webhook).to_unsafe_h
    sign = params[:sign]

    unless Cryptomus::WebhookValidator.validate(payload:, sign:)
      Rails.logger.info { 'invalid signature' }
      head 400
      return
    end

    unless payload['is_final']
      Rails.logger.info { "status is not final: #{payload['status']}" }
      head 200
      return
    end

    payment = Payment.find(payload['order_id'])
    CryptomusPayment::CheckStatus.call(payment:)
    head 200
  end

  private

  def handle_exceptions(error)
    log_error(error)
    capture_error(error)
    head 500
  end

  def capture_extra
    {
      payload: params.except(:controller, :action, :sign).to_unsafe_h,
      sign: params[:sign]
    }
  end
end
