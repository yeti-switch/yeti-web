# frozen_string_literal: true

module CustomCdrReport
  class GenerateData < ApplicationService
    parameter :report

    def call
      report.with_lock do
        validate!

        insert_report_data
        report.update!(completed: true)
        Reporter::CustomCdr.new(report).save!
      end
    end

    private

    def validate!
      raise Error, "Report::CustomCdr ##{report.id} already completed" if report.completed?
    end

    def insert_report_data
      SqlCaller::Cdr.execute(
        "INSERT INTO cdr_custom_report_data(
            report_id,
            #{report.group_by.join(', ')},
            agg_calls_count,
            agg_calls_duration,
            agg_customer_calls_duration,
            agg_vendor_calls_duration,
            agg_customer_price,
            agg_customer_price_no_vat,
            agg_vendor_price,
            agg_profit,
            agg_asr_origination,
            agg_asr_termination,
            agg_calls_acd
          )
          #{build_scope.to_sql}"
      )
    end

    def build_scope
      scope = Cdr::Cdr.select(
        report.id,
        *report.group_by,
        'count(id)',
        'coalesce(sum(duration),0)',
        'coalesce(sum(customer_duration),0)',
        'coalesce(sum(vendor_duration),0)',
        'sum(customer_price)',
        'sum(customer_price_no_vat)',
        'sum(vendor_price)',
        'sum(profit)',
        'coalesce(count(nullif(success AND is_last_cdr,false))::float/nullif(count(nullif(is_last_cdr,false)),0)::float,0)',
        'coalesce(count(nullif(success,false))::float/nullif(count(id),0)::float,0)',
        'sum(duration)::float/nullif(count(nullif(success,false)),0)::float'
      ).where(
        'time_start >= ? AND time_start < ?', report.date_start, report.date_end
      ).group(
        *report.group_by
      )

      scope = scope.where(customer_id: report.customer_id) if report.customer_id
      scope = scope.where(report.filter) if report.filter.present?

      scope
    end
  end
end
