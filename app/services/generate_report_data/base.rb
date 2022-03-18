# frozen_string_literal: true

module GenerateReportData
  class Base < ApplicationService
    parameter :report

    def call
      report.with_lock do
        validate!

        insert_report_data
        report.update!(completed: true)
        send_report!
      end
    end

    private

    def report_name
      self.class.name.demodulize
    end

    def send_report!
      sender_class = "SendReport::#{report_name}".constantize
      sender_class.call(report: report)
    end

    def validate!
      raise Error, "Report::CustomCdr ##{report.id} already completed" if report.completed?
    end

    def insert_report_data
      raise NotImplementedError
    end
  end
end
