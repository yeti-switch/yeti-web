# frozen_string_literal: true

module GenerateReportData
  class CustomerTraffic < Base
    private

    def insert_report_data
      insert_full_data
      insert_data_by_vendor
      insert_data_by_destination
    end

    def insert_full_data
      SqlCaller::Cdr.execute(
        "INSERT INTO reports.customer_traffic_report_data_full(
            report_id,
            vendor_id,
            destination_prefix,
            dst_country_id,
            dst_network_id,
            calls_count,
            short_calls_count,
            success_calls_count,
            calls_duration,
            customer_calls_duration,
            vendor_calls_duration,
            acd,
            asr,
            origination_cost ,termination_cost,
            profit,
            first_call_at, last_call_at
        )
        #{cdr_scope.to_sql}"
      )
    end

    def insert_data_by_vendor
      SqlCaller::Cdr.execute(
        "INSERT INTO reports.customer_traffic_report_data_by_vendor(
            report_id,
            vendor_id,
            calls_count,
            short_calls_count,
            success_calls_count,
            calls_duration,
            customer_calls_duration,
            vendor_calls_duration,
            acd,
            asr,
            origination_cost ,
            termination_cost,
            profit,
            first_call_at,
            last_call_at
        )
        SELECT
          ?,
          vendor_id,
          sum(calls_count),
          sum(short_calls_count),
          sum(success_calls_count),
          sum(calls_duration),
          sum(customer_calls_duration),
          sum(vendor_calls_duration),
          sum(calls_duration)::float/sum(nullif(success_calls_count,0))::float,
          sum(success_calls_count)::float/sum(nullif(calls_count,0))::float,
          sum(origination_cost),
          sum(termination_cost),
          sum(profit),
          min(first_call_at),
          max(last_call_at)
        FROM reports.customer_traffic_report_data_full
        WHERE
          report_id=?
        GROUP BY vendor_id",
        report.id,
        report.id
      )
    end

    def insert_data_by_destination
      SqlCaller::Cdr.execute(
        "INSERT INTO reports.customer_traffic_report_data_by_destination(
            report_id,
            destination_prefix,
            dst_country_id,
            dst_network_id,
            calls_count,
            short_calls_count,
            success_calls_count,
            calls_duration,
            customer_calls_duration,
            vendor_calls_duration,
            acd,
            asr,
            origination_cost ,
            termination_cost,
            profit,
            first_call_at,
            last_call_at
        )
        SELECT
          ?,
          destination_prefix,
          dst_country_id,
          dst_network_id,
          sum(calls_count),
          sum(short_calls_count),
          sum(success_calls_count),
          sum(calls_duration),
          sum(customer_calls_duration),
          sum(vendor_calls_duration),
          sum(calls_duration)::float/sum(nullif(success_calls_count,0))::float,
          sum(success_calls_count)::float/sum(nullif(calls_count,0))::float,
          sum(origination_cost),
          sum(termination_cost),
          sum(profit),
          min(first_call_at),
          max(last_call_at)
        from reports.customer_traffic_report_data_full
        WHERE
          report_id=?
        GROUP BY destination_prefix, dst_country_id, dst_network_id",
        report.id,
        report.id
      )
    end

    def cdr_scope
      Cdr::Cdr.select(
        report.id,
        'vendor_id',
        'destination_prefix',
        'dst_country_id',
        'dst_network_id',
        'count(id)',
        Cdr::Cdr.sanitize_sql_array(["count(id) FILTER ( WHERE duration <= ? AND success )", GuiConfig.short_call_length ]),
        'count(nullif(success,false))',
        'count(id) FILTER ( WHERE success )',
        'coalesce(sum(duration),0)',
        'coalesce(sum(customer_duration),0)',
        'coalesce(sum(vendor_duration),0)',
        'sum(duration)::float/nullif(count(nullif(success,false)),0)::float',
        'count(nullif(success,false))::float/nullif(count(id),0)::float',
        'sum(customer_price), sum(vendor_price)',
        'sum(profit)',
        'min(time_start)',
        'max(time_start)'
      ).where(
        'time_start >= ? AND time_start < ? and customer_id = ?',
        report.date_start, report.date_end, report.customer_id
      ).group(
        :vendor_id,
        :destination_prefix,
        :dst_country_id,
        :dst_network_id
      )
    end
  end
end
