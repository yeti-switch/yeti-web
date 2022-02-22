# frozen_string_literal: true

module CustomCdrReport
  class Create < ApplicationService
    parameter :customer
    parameter :date_start
    parameter :date_end
    parameter :filter
    parameter :group_by
    parameter :send_to

    def call
      validate!
      report = Report::CustomCdr.create!(
        customer: customer,
        date_start: date_start,
        date_end: date_end,
        filter: filter.presence,
        group_by: group_by,
        send_to: send_to.presence
      )

      Worker::CustomCdrReportJob.perform_later(report.id)
    end

    private

    def validate!
      raise Error, 'date_start must be present' if date_start.blank?
      raise Error, 'date_start must be present' if date_end.blank?
      raise Error, 'group_by must be present' if group_by.blank?
      if group_by.any? { |field| Report::CustomData::CDR_COLUMNS.exclude?(field.to_sym) }
        raise Error, 'group_by are invalid'
      end
      if send_to.present? && send_to.count != Billing::Contact.where(id: send_to).count
        raise Error, 'send_to are invalid'
      end
    end
  end
end
