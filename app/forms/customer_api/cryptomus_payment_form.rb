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
          type_id: Payment::CONST::TYPE_ID_CRYPTOMUS,
          status_id: Payment::CONST::STATUS_ID_PENDING
        )
        @url = CryptomusPayment::Create.call(order_id: payment.id, amount:)
        @uuid = payment.reload.uuid
      end
    end
  end
end
