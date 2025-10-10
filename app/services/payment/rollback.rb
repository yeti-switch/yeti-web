# frozen_string_literal: true

class Payment
  class Rollback < ApplicationService
    parameter :payment

    Error = Class.new(ApplicationService::Error)

    def call
      Payment.transaction do
        raise_if_invalid!

        payment.update!(status_id: Payment::CONST::STATUS_ID_ROLLED_BACK, rolledback_at: DateTime.now.utc)
        payment.account.update!(balance: payment.account.balance - payment.amount)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
        raise Error, e.message
      end
    end

    def raise_if_invalid!
      raise Error, 'Status of payment should be completed' if payment.status_id != Payment::CONST::STATUS_ID_COMPLETED
    end
  end
end
