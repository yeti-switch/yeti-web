# frozen_string_literal: true

class Api::Rest::Customer::V1::OutgoingActiveCallsController < Api::Rest::Customer::V1::ReportBaseController
  def self.clickhouse_report_class
    ClickhouseReport::CustomerOutgoingActiveCalls
  end
end
