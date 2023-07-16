# frozen_string_literal: true

module CryptomusPayment
  class CheckStatus < ApplicationService
    Error = Class.new(StandardError)

    parameter :payment, required: true

    SUCCESS_STATUSES = %w[paid paid_over].freeze

    def call
      payment.with_lock do
        raise Error, 'Payment is not pending' unless payment.pending?

        cr_payment = Cryptomus::Client.payment(order_id: payment.id.to_s)
        unless cr_payment[:result][:is_final]
          raise Error, "Cryptomus Payment status is not final: #{cr_payment[:result][:status]}"
        end

        if cr_payment[:result][:status].in?(SUCCESS_STATUSES)
          amount = cr_payment[:result][:payer_amount].to_d
          payment.update!(amount:, status_id: Payment::CONST::STATUS_ID_COMPLETED)
        else
          payment.update!(status_id: Payment::CONST::STATUS_ID_CANCELED)
        end
      end
    end
  end
end
