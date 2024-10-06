# frozen_string_literal: true

module Report
  class IntervalCdrForm < BaseForm
    with_model_name 'IntervalCdrReport'
    with_policy_class 'Report::IntervalCdrPolicy'

    attribute :aggregator_id, :integer
    attribute :filter, :string
    attribute :aggregate_by, :string
    attribute :interval_length, :integer
    attribute :group_by, :string, array: { reject_blank: true }, default: []
    attribute :send_to, :integer, array: { reject_blank: true }

    validate :validate_group_by
    validate :validate_send_to
    validate :validate_aggregation_function
    validates :interval_length, presence: true
    validates :interval_length, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
    validates :aggregate_by, presence: true
    validates :aggregate_by, inclusion: { in: Report::IntervalCdr::CDR_AGG_COLUMNS.map(&:to_s) }, allow_blank: true

    # @!method aggregation_function
    define_memoizable :aggregation_function, apply: lambda {
      return if aggregator_id.nil?

      Report::IntervalAggregator.find_by(id: aggregator_id)
    }

    private

    def _save
      CreateReport::IntervalCdr.call(
        date_start: date_start,
        date_end: date_end,
        aggregation_function: aggregation_function,
        aggregate_by: aggregate_by,
        interval_length: interval_length,
        filter: filter.presence,
        group_by: group_by,
        send_to: send_to.presence
      )
    rescue CreateReport::CustomCdr::Error => e
      errors.add(:base, e.message)
    end

    def validate_group_by
      return if group_by.blank?

      if group_by.any? { |field| Report::IntervalCdr::CDR_COLUMNS.exclude?(field.to_sym) }
        errors.add(:group_by, :invalid)
      end
    end

    def validate_send_to
      return if send_to.blank?

      if send_to.count != Billing::Contact.where(id: send_to).count
        errors.add(:send_to, :invalid)
      end
    end

    def validate_aggregation_function
      if aggregation_function.nil?
        errors.add(:aggregation_function, :blank) if aggregator_id.nil?
        errors.add(:aggregation_function, :invalid) if aggregator_id
      end
    end
  end
end
