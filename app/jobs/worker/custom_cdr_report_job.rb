# frozen_string_literal: true

module Worker
  class CustomCdrReportJob < ::ApplicationJob
    include GoodJob::ActiveJobExtensions::Concurrency

    queue_as 'report'
    # note: will retry infinitely with polynomially_longer backoff
    good_job_control_concurrency_with perform_limit: 1

    def perform(report_id)
      report = Report::CustomCdr.find_by(id: report_id)
      return if report.nil?

      GenerateReportData::CustomCdr.call(report: report)
    end
  end
end
