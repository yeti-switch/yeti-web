# frozen_string_literal: true

class Api::Rest::Customer::V1::TerminationStatisticsQualityController < Api::Rest::Customer::V1::ReportBaseController
  def self.clickhouse_report_class
    ClickhouseReport::TerminationStatisticQuality
  end
end
