# frozen_string_literal: true

module CustomerApi
  class CryptomusPaymentForm < ApplicationForm
    EXPIRATION_SEC = 12 * 60 * 60 # expires in 12 hours

    def self.policy_class
      PaymentPolicy
    end

    attr_reader :uuid, :url

    attr_accessor :customer_id, :allowed_account_ids

    attribute :amount, :decimal
    attribute :notes, :string
    attribute :account_id, :string

    validates :amount, presence: true
    validates :amount, numericality: { greater_than_or_equal_to: 0.01 }, allow_nil: true

    validates :account, presence: true

    # @!method account
    define_memoizable :account, apply: lambda {
      return if account_id.nil?

      scope = Account.where(contractor_id: customer_id)
      scope = scope.where(id: allowed_account_ids) if allowed_account_ids.present?
      scope.find_by(uuid: account_id)
    }

    def persisted?
      uuid.present?
    end

    private

    def _save
      ApplicationRecord.transaction do
        payment = Payment.create!(
          account:,
          amount:,
          notes:,
          status_id: Payment::CONST::STATUS_ID_PENDING
        )
        crypto_payment = create_cryptomus_payment(payment)
        @url = crypto_payment[:result][:url]
        @uuid = payment.reload.uuid
      end
    end

    def create_cryptomus_payment(payment)
      Cryptomus::Client.create_payment(
        order_id: payment.id.to_s,
        amount: amount.to_s,
        currency: 'USD',
        currencies: available_currencies,
        url_callback: YetiConfig.cryptomus&.url_callback,
        lifetime: EXPIRATION_SEC,
        subtract: 100 # customer will pay 100% of commission
      )
    end

    def available_currencies
      response = Cryptomus::Client.list_services
      currencies = response[:result].map { |currency| currency[:currency] }.uniq
      currencies.map { |currency| { currency: } }
    end
  end
end
