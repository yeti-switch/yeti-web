# frozen_string_literal: true

class CustomCdrReportForm < ApplicationForm
  with_model_name 'CustomCdrReport'
  with_policy_class 'Report::CustomCdrPolicy'
  include Hints

  attr_reader :report
  delegate :id, to: :report, allow_nil: true

  attribute :customer_id, :integer
  attribute :date_start, :datetime
  attribute :date_end, :datetime
  attribute :filter, :string
  attribute :group_by, :string, array: { reject_blank: true }
  attribute :send_to, :integer, array: { reject_blank: true }

  validates :date_start, :date_end, presence: true
  validate :validate_customer
  validate :validate_group_by
  validate :validate_send_to

  # @!method customer
  define_memoizable :customer, apply: lambda {
    return if customer_id.nil?

    Contractor.customers.find_by(id: customer_id)
  }

  private

  def _save
    CustomCdrReport::Create.call(
      date_start: date_start,
      date_end: date_end,
      customer: customer,
      filter: filter.presence,
      group_by: group_by,
      send_to: send_to.presence
    )
  rescue CustomCdrReport::Create::Error => e
    errors.add(:base, e.message)
  end

  def validate_group_by
    if group_by.blank?
      errors.add(:group_by, :blank)
      return
    end

    if group_by.any? { |field| Report::CustomData::CDR_COLUMNS.exclude?(field.to_sym) }
      errors.add(:group_by, :invalid)
    end
  end

  def validate_send_to
    return if send_to.blank?

    if send_to.count != Billing::Contact.where(id: send_to).count
      errors.add(:send_to, :invalid)
    end
  end

  def validate_customer
    if customer_id && customer.nil?
      errors.add(:customer_id, :invalid)
    end
  end
end
