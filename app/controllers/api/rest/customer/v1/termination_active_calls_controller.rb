# frozen_string_literal: true

class Api::Rest::Customer::V1::TerminationActiveCallsController < Api::Rest::Customer::V1::ReportBaseController
  def self.clickhouse_report_class
    ClickhouseReport::TerminationActiveCalls
  end
end
