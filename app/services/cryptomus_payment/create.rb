# frozen_string_literal: true

module CryptomusPayment
  class Create < ApplicationService
    parameter :order_id, required: true
    parameter :amount, required: true

    Error = Class.new(StandardError)

    CURRENCY = 'USDT'
    NETWORK = 'TRON'
    EXPIRATION_SECONDS = 12 * 60 * 60 # expires in 12 hours

    def call
      crypto_payment = Cryptomus::Client.create_payment(
        order_id: order_id.to_s,
        amount: amount.to_s,
        currency: CURRENCY,
        network: NETWORK,
        url_callback: YetiConfig.cryptomus&.url_callback,
        url_return: YetiConfig.cryptomus&.url_return,
        lifetime: EXPIRATION_SECONDS,
        subtract: 100, # customer will pay 100% of commission
        is_payment_multiple: false
      )
      crypto_payment[:result][:url]
    rescue Cryptomus::Errors::ApiError => e
      raise Error, e.message
    end
  end
end
