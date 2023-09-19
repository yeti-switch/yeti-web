class CustomReportSucessfulCallsCount < ActiveRecord::Migration[7.0]
  def up

    execute %q{
      alter table reports.cdr_custom_report_data
        add agg_successful_calls_count bigint,
        add agg_short_calls_count bigint,
        add agg_uniq_calls_count bigint;
    }
  end

    def down
    execute %q{
      alter table reports.cdr_custom_report_data
        drop column agg_successful_calls_count,
        drop column agg_short_calls_count,
        drop column agg_uniq_calls_count;
    }
  end

end
