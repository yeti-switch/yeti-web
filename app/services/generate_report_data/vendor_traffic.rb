# frozen_string_literal: true

module GenerateReportData
  class VendorTraffic < Base
    private

    def insert_report_data
      SqlCaller::Cdr.execute(
        "INSERT INTO reports.vendor_traffic_report_data(
          report_id,
          customer_id,
          calls_count,
          short_calls_count,
          success_calls_count,
          calls_duration,
          customer_calls_duration,
          vendor_calls_duration,
          acd,
          asr,
          origination_cost,
          termination_cost,
          profit,
          first_call_at,
          last_call_at
        )
        #{cdr_scope.to_sql}"
      )
    end

    def cdr_scope
      Cdr::Cdr.select(
        report.id,
        'customer_id',
        'count(id)',
        "count(nullif(duration>#{GuiConfig.short_call_length},false))",
        'count(nullif(success,false))',
        'coalesce(sum(duration),0)',
        'coalesce(sum(customer_duration),0)',
        'coalesce(sum(vendor_duration),0)',
        'sum(duration)::float/nullif(count(nullif(success,false)),0)::float',
        'count(nullif(success,false))::float/nullif(count(id),0)::float',
        'sum(customer_price)',
        'sum(vendor_price)',
        'sum(profit)',
        'min(time_start)',
        'max(time_start)'
      ).where(
        'time_start >= ? AND time_start < ? AND vendor_id = ?',
        report.date_start, report.date_end, report.vendor_id
      ).group(
        :customer_id
      )
    end
  end
end
