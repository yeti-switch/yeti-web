# frozen_string_literal: true

module CreateReport
  class Base < ApplicationService
    parameter :date_start
    parameter :date_end
    parameter :send_to

    def call
      validate!
      report = create_report!

      Worker::GenerateReportDataJob.perform_later(report_name, report.id)
    end

    private

    def report_name
      self.class.name.demodulize
    end

    def create_report!
      raise NotImplementedError
    end

    def validate!
      raise Error, 'date_start must be present' if date_start.blank?
      raise Error, 'date_start must be present' if date_end.blank?
      if send_to.present? && send_to.count != Billing::Contact.where(id: send_to).count
        raise Error, 'send_to are invalid'
      end
    end
  end
end
