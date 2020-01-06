class VendorReportDurations < ActiveRecord::Migration[5.2]
  def up
    execute %q{
      alter table reports.vendor_traffic_report_data
        add customer_calls_duration bigint,
        add vendor_calls_duration bigint;

      alter table reports.customer_traffic_report_data_full
        add customer_calls_duration bigint,
        add vendor_calls_duration bigint;
      update reports.customer_traffic_report_data_full set customer_calls_duration=calls_duration, vendor_calls_duration=calls_duration;
      alter table reports.customer_traffic_report_data_full
        alter column customer_calls_duration set not null,
        alter column vendor_calls_duration set not null;

      alter table reports.customer_traffic_report_data_by_destination
        add customer_calls_duration bigint,
        add vendor_calls_duration bigint;
      update reports.customer_traffic_report_data_by_destination set customer_calls_duration=calls_duration, vendor_calls_duration=calls_duration;
      alter table reports.customer_traffic_report_data_by_destination
        alter column customer_calls_duration set not null,
        alter column vendor_calls_duration set not null;

      alter table reports.customer_traffic_report_data_by_vendor
        add customer_calls_duration bigint,
        add vendor_calls_duration bigint;

      alter table billing.invoices
        add customer_calls_duration bigint,
        add vendor_calls_duration bigint;
      update billing.invoices set customer_calls_duration=calls_duration, vendor_calls_duration=calls_duration;
      alter table billing.invoices
        alter column customer_calls_duration set not null,
        alter column vendor_calls_duration set not null;

      alter table billing.invoice_destinations
        add customer_calls_duration bigint,
        add vendor_calls_duration bigint;

      alter table billing.invoice_networks
        add customer_calls_duration bigint,
        add vendor_calls_duration bigint;

      alter table reports.cdr_custom_report_data
        add agg_customer_calls_duration bigint,
        add agg_vendor_calls_duration bigint,
        add agg_customer_price_no_vat numeric;
    }
  end

  def down
    execute %q{
      alter table reports.vendor_traffic_report_data
        drop column customer_calls_duration,
        drop column vendor_calls_duration;

      alter table reports.customer_traffic_report_data_full
        drop column customer_calls_duration,
        drop column vendor_calls_duration;

      alter table reports.customer_traffic_report_data_by_destination
        drop column customer_calls_duration,
        drop column vendor_calls_duration;

      alter table reports.customer_traffic_report_data_by_vendor
        drop column customer_calls_duration,
        drop column vendor_calls_duration;

      alter table billing.invoices
        drop column customer_calls_duration,
        drop column vendor_calls_duration;

      alter table billing.invoice_destinations
        drop column customer_calls_duration,
        drop column vendor_calls_duration;

      alter table billing.invoice_networks
        drop column customer_calls_duration,
        drop column vendor_calls_duration;

      alter table reports.cdr_custom_report_data
        drop column agg_customer_calls_duration,
        drop column agg_vendor_calls_duration,
        drop column agg_customer_price_no_vat;
    }
  end
end
