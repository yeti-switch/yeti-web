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

      if payment.completed?
        if payload[:merchant_amount].to_d != payment.metadata['merchant_amount'].to_d
          raise Error, "success webhook received with merchant_amount #{payload[:merchant_amount]} but payment is completed with merchant_amount #{payment.metadata['merchant_amount']}"
        end

        return
      end

      payment.update!(
        amount: merchant_amount_in_account_currency,
        status_id: Payment::CONST::STATUS_ID_COMPLETED,
        metadata: payment.metadata.merge('merchant_amount' => payload[:merchant_amount].to_f)
      )
    end

    def handle_failed_status
      raise Error, 'failed webhook received but payment is completed' if payment.completed?

      payment.update!(status_id: Payment::CONST::STATUS_ID_CANCELED)
    end

    def merchant_amount_in_account_currency
      usdt_rate = payment.metadata['usdt_rate']
      (payload[:merchant_amount].to_d * usdt_rate / payment.account.currency.rate).round(8)
    end

    define_memoizable :payment, apply: lambda {
      return if payload[:order_id].blank?

      Payment.find_by id: payload[:order_id]
    }
  end
end
