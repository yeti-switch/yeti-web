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
      Cryptomus::Client.payment(order_id: payment.id.to_s)
    rescue Cryptomus::Client::ApiError => e
      capture_error!(e, extra: { payment_id: payment.id, status: e.status, body: e.response_body })
    end
  end
end
