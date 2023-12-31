class FixReportColumns < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      alter table reports.cdr_interval_report_data
        rename column vendor_billed to dialpeer_reverse_billing;
      alter table reports.cdr_interval_report_data
        rename column customer_billed to destination_reverse_billing;

      alter table reports.cdr_custom_report_data
        rename column vendor_billed to dialpeer_reverse_billing;
      alter table reports.cdr_custom_report_data
        rename column customer_billed to destination_reverse_billing;
    }
  end

  def down
    execute %q{
      alter table reports.cdr_interval_report_data
        rename column dialpeer_reverse_billing to vendor_billed;
      alter table reports.cdr_interval_report_data
        rename column destination_reverse_billing to customer_billed;

      alter table reports.cdr_custom_report_data
        rename column dialpeer_reverse_billing to vendor_billed;
      alter table reports.cdr_custom_report_data
        rename column destination_reverse_billing to customer_billed;
    }
  end
end
