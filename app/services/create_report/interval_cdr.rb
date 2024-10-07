# frozen_string_literal: true

module CreateReport
  class IntervalCdr < Base
    parameter :filter
    parameter :group_by, default: []
    parameter :aggregation_function
    parameter :aggregate_by
    parameter :interval_length

    private

    def create_report!
      Report::IntervalCdr.create!(
        aggregation_function: aggregation_function,
        aggregate_by: aggregate_by,
        interval_length: interval_length,
        date_start: date_start,
        date_end: date_end,
        filter: filter.presence,
        group_by: group_by,
        send_to: send_to.presence
      )
    end

    def validate!
      super
      raise Error, 'aggregation_function must be present' if aggregation_function.blank?
      raise Error, 'aggregate_by must be present' if aggregate_by.blank?
      raise Error, 'aggregate_by is invalid' if Report::IntervalCdr::CDR_AGG_COLUMNS.exclude?(aggregate_by.to_sym)
      raise Error, 'interval_length must be present' if interval_length.blank?
      raise Error, 'interval_length is invalid' if interval_length.to_i <= 0
      if group_by&.any? { |field| Report::IntervalCdr::CDR_COLUMNS.exclude?(field.to_sym) }
        raise Error, 'group_by are invalid'
      end
    end
  end
end
