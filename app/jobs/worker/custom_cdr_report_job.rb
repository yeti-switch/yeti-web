# frozen_string_literal: true

module Worker
  class CustomCdrReportJob < ::ApplicationJob
    queue_as 'report'
    unique_name 'Worker::CustomCdrReportJob'

    def perform(report_id)
      report = Report::CustomCdr.find_by(id: report_id)
      return if report.nil?

      CustomCdrReport::GenerateData.call(report: report)
    end
  end
end
