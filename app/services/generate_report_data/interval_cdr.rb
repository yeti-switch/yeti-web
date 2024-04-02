# frozen_string_literal: true

module GenerateReportData
  class IntervalCdr < Base
    private

    def insert_report_data
      group_by_values = report.group_by&.map { |col| "#{col}," }&.join(' ')

      SqlCaller::Cdr.execute(
        "INSERT INTO reports.cdr_interval_report_data(
          report_id,
          timestamp,
          #{group_by_values.presence}
          aggregated_value
        )
        #{cdr_scope.to_sql}"
      )
    end

    def cdr_scope
      scope = Cdr::Cdr.select(
        report.id,
        Cdr::Cdr.sanitize_sql_array([
                                      "timestamp 'epoch' + ( ?::interval * (date_part('epoch',time_start)::bigint/date_part('epoch', ?::interval)::bigint))",
                                      "#{report.interval_length} minutes",
                                      "#{report.interval_length} minutes"
                                    ]),
        *report.group_by,
        report.aggregation
      ).where(
        'time_start >= ? AND time_start < ?', report.date_start, report.date_end
      ).group(
        Cdr::Cdr.sanitize_sql_array(["(date_part('epoch',time_start)::bigint/date_part('epoch', ?::interval)::bigint)", "#{report.interval_length} minutes"]),
        *report.group_by
      )

      scope = scope.where(report.filter) if report.filter.present?
      scope
    end
  end
end
