# frozen_string_literal: true

module Report
  class CustomerTrafficForm < BaseForm
    with_model_name 'CustomerTrafficReport'
    with_policy_class 'Report::CustomerTrafficPolicy'

    attribute :customer_id, :integer
    attribute :send_to, :integer, array: { reject_blank: true }

    validate :validate_customer
    validate :validate_send_to

    # @!method customer
    define_memoizable :customer, apply: lambda {
      return if customer_id.nil?

      Contractor.customers.find_by(id: customer_id)
    }

    private

    def _save
      CreateReport::CustomerTraffic.call(
        date_start: date_start,
        date_end: date_end,
        customer: customer,
        send_to: send_to.presence
      )
    rescue CreateReport::CustomerTraffic::Error => e
      errors.add(:base, e.message)
    end

    def validate_send_to
      return if send_to.blank?

      if send_to.count != Billing::Contact.where(id: send_to).count
        errors.add(:send_to, :invalid)
      end
    end

    def validate_customer
      if customer.nil?
        errors.add(:customer_id, :blank) if customer_id.nil?
        errors.add(:customer_id, :invalid) if customer_id
      end
    end
  end
end
