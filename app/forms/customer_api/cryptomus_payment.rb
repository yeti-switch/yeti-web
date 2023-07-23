# frozen_string_literal: true

module CustomerApi
  class CryptomusPayment
    include ActiveModel::Model
    include ActiveModel::Attributes
    include WithActiveModelArrayAttribute
    include Memoizable
    include CaptureError::BaseMethods

    attr_accessor :payment
    delegate :uuid, to: :payment

    def url
      payment_info.dig(:result, :url)
    end

    # @!method payment_info [Hash]
    define_memoizable :payment_info, apply: lambda {
      fetch_payment_info
    }

    private

    def fetch_payment_info
      CaptureError.with_exception_context(extra: { payment_id: payment.id }) do
        Cryptomus::Client.payment(order_id: payment.id.to_s)
      end
    end
  end
end
