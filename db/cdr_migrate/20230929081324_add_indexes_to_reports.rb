class AddIndexesToReports < ActiveRecord::Migration[7.0]
  def up
    execute %q{
      drop index reports.cdr_custom_report_id_idx;

      create index cdr_custom_report_data_report_id_idx on reports.cdr_custom_report_data using btree(report_id);
      create index cdr_interval_report_data_report_id_idx on reports.cdr_interval_report_data using btree(report_id);
      create index customer_traffic_report_data_by_destination_report_id_idx on reports.customer_traffic_report_data_by_destination using btree(report_id);
      create index customer_traffic_report_data_full_report_id_idx on reports.customer_traffic_report_data_full using btree(report_id);

      drop table report_vendors_data;
      drop table report_vendors;

    }
  end

  def down
    execute %q{
      create unique index cdr_custom_report_id_idx on reports.cdr_custom_report using btree(id) where id is not null;

      drop index reports.cdr_custom_report_data_report_id_idx;
      drop index reports.cdr_interval_report_data_report_id_idx;
      drop index reports.customer_traffic_report_data_by_destination_report_id_idx;
      drop index reports.customer_traffic_report_data_full_report_id_idx;

      create table reports.report_vendors(
        id serial primary key,
        created_at timestamptz not null default now(),
        start_date timestamptz not null,
        end_date timestamptz not null
      );

      create table reports.report_vendors_data(
        id bigserial primary key,
        report_id integer not null references reports.report_vendors(id),
        calls_count bigint
      );
    }
  end
end
