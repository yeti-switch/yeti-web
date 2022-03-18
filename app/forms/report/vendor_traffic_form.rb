# frozen_string_literal: true

module Report
  class VendorTrafficForm < BaseForm
    with_model_name 'VendorTrafficReport'
    with_policy_class 'Report::VendorTrafficPolicy'

    attribute :vendor_id, :integer
    attribute :send_to, :integer, array: { reject_blank: true }

    validate :validate_vendor
    validate :validate_send_to

    # @!method customer
    define_memoizable :vendor, apply: lambda {
      return if vendor_id.nil?

      Contractor.vendors.find_by(id: vendor_id)
    }

    private

    def _save
      CreateReport::VendorTraffic.call(
        date_start: date_start,
        date_end: date_end,
        vendor: vendor,
        send_to: send_to.presence
      )
    rescue CreateReport::VendorTraffic::Error => e
      errors.add(:base, e.message)
    end

    def validate_send_to
      return if send_to.blank?

      if send_to.count != Billing::Contact.where(id: send_to).count
        errors.add(:send_to, :invalid)
      end
    end

    def validate_vendor
      if vendor.nil?
        errors.add(:vendor_id, :blank) if vendor_id.nil?
        errors.add(:vendor_id, :invalid) if vendor_id
      end
    end
  end
end
