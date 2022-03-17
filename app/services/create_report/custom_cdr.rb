# frozen_string_literal: true

module CreateReport
  class CustomCdr < Base
    parameter :customer
    parameter :filter
    parameter :group_by

    private

    def create_report!
      Report::CustomCdr.create!(
        customer: customer,
        date_start: date_start,
        date_end: date_end,
        filter: filter.presence,
        group_by: group_by,
        send_to: send_to.presence
      )
    end

    def validate!
      super
      raise Error, 'group_by must be present' if group_by.blank?
      if group_by.any? { |field| Report::CustomCdr::CDR_COLUMNS.exclude?(field.to_sym) }
        raise Error, 'group_by are invalid'
      end
    end
  end
end
