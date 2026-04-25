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
      usdt_currency = Billing::Currency.find_by(name: 'USDT')
      if usdt_currency.nil?
        Rails.logger.error { 'CryptomusPayment: USDT currency is not configured in Billing::Currency' }
        errors.add(:base, 'Configuration error')
        return false
      end

      usdt_amount = (amount * account.currency.rate / usdt_currency.rate).round(2)

      ApplicationRecord.transaction do
        payment = Payment.create!(
          account:,
          amount:,
          notes:,
          metadata: { usdt_rate: usdt_currency.rate },
          type_id: Payment::CONST::TYPE_ID_CRYPTOMUS,
          status_id: Payment::CONST::STATUS_ID_PENDING
        )
        @url = ::CryptomusPayment::Create.call(order_id: payment.id, amount: usdt_amount)
        @uuid = payment.reload.uuid
      end
    end
  end
end
