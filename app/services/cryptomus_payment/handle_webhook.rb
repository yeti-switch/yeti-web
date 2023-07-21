# frozen_string_literal: true

module CryptomusPayment
  class HandleWebhook < ApplicationService
    Error = Class.new(StandardError)

    parameter :payload, required: true

    SUCCESS_STATUSES = %w[paid paid_over].freeze

    def call
      raise Error, "Payment with id #{payload[:order_id].inspect} not found" if payment.nil?

      payment.with_lock do
        raise Error, 'Payment type is not cryptomus' unless payment.type_cryptomus?

        unless payload[:is_final]
          Rails.logger.info { "Cryptomus Payment status is not final: #{payload[:status]}" }
          return
        end

        if payload[:status].in?(SUCCESS_STATUSES)
          handle_success_status
        else
          handle_failed_status
        end
      end
    end

    private

    def handle_success_status
      raise Error, 'success webhook received but payment is canceled' if payment.canceled?
      if payment.completed? && payment.amount != merchant_amount_usd
        raise Error, "success webhook received with amount #{merchant_amount_usd} but payment is completed with amount #{payment.amount}"
      end

      payment.update!(
        amount: merchant_amount_usd,
        status_id: Payment::CONST::STATUS_ID_COMPLETED
      )
    end

    def handle_failed_status
      raise Error, 'failed webhook received but payment is completed' if payment.completed?

      payment.update!(status_id: Payment::CONST::STATUS_ID_CANCELED)
    end

    # in CustomerApi::CryptomusPaymentForm we crete cryptomus payment in USDT
    # so we can use merchant_amount as payment amount because USDT equal to USD.
    # webhook payload nor payment info does not contain merchant amount in USD
    # (values that merchant received to the USD balance).
    def merchant_amount_usd
      payload[:merchant_amount].to_d
    end

    define_memoizable :payment, apply: lambda {
      return if payload[:order_id].blank?

      Payment.find_by id: payload[:order_id]
    }
  end
end
