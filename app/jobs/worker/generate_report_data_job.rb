# frozen_string_literal: true

module Worker
  class GenerateReportDataJob < ::ApplicationJob
    queue_as 'report'

    def perform(report_name, report_id)
      report_class = "Report::#{report_name}".constantize
      report = report_class.find_by(id: report_id)
      return if report.nil?

      service_class = "GenerateReportData::#{report_name}".constantize
      service_class.call(report: report)
    end
  end
end
