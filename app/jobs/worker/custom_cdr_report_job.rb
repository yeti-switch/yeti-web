# frozen_string_literal: true

module Worker
  class CustomCdrReportJob < ::ApplicationJob
    queue_as 'report'
    unique_name 'Worker::CustomCdrReportJob'
    # TODO: remove

    def perform(report_id)
      report = Report::CustomCdr.find_by(id: report_id)
      return if report.nil?

      GenerateReportData::CustomCdr.call(report: report)
    end
  end
end
