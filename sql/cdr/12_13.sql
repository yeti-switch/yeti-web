begin;
insert into sys.version(number,comment) values(13,'Migration to timestamp with timezone');

alter TABLE cdr.cdr ALTER COLUMN time_start TYPE TIMESTAMPTZ,
ALTER COLUMN time_connect TYPE TIMESTAMPTZ,
alter COLUMN time_end TYPE TIMESTAMPTZ;

alter TABLE billing.invoices ALTER COLUMN start_date TYPE TIMESTAMPTZ,
ALTER COLUMN end_date type TIMESTAMPTZ,
ALTER COLUMN first_cdr_date type TIMESTAMPTZ,
ALTER COLUMN last_cdr_date type TIMESTAMPTZ;

alter TABLE cdr.cdr_archive ALTER COLUMN time_start TYPE TIMESTAMPTZ,
ALTER COLUMN time_connect TYPE TIMESTAMPTZ,
alter COLUMN time_end TYPE TIMESTAMPTZ;


alter table reports.cdr_custom_report ALTER COLUMN date_start TYPE TIMESTAMPTZ,
alter COLUMN date_end type TIMESTAMPTZ,
ALTER COLUMN created_at TYPE TIMESTAMPTZ;

alter table reports.cdr_custom_report_data ALTER COLUMN time_start TYPE TIMESTAMPTZ,
ALTER COLUMN time_connect TYPE TIMESTAMPTZ,
alter COLUMN time_end TYPE TIMESTAMPTZ;

alter table reports.cdr_interval_report ALTER COLUMN date_start TYPE TIMESTAMPTZ,
alter COLUMN date_end type TIMESTAMPTZ,
ALTER COLUMN created_at TYPE TIMESTAMPTZ;

alter table reports.cdr_interval_report_data ALTER COLUMN time_start TYPE TIMESTAMPTZ,
ALTER COLUMN time_connect TYPE TIMESTAMPTZ,
alter COLUMN time_end TYPE TIMESTAMPTZ,
ALTER column timestamp type timestamptz;

alter TABLE reports.report_vendors alter COLUMN created_at TYPE TIMESTAMPTZ,
ALTER COLUMN start_date type TIMESTAMPTZ,
ALTER COLUMN end_date type TIMESTAMPTZ;

/*

alter TABLE reports.customer_reports alter COLUMN created_at TYPE TIMESTAMPTZ,
ALTER COLUMN start_date type TIMESTAMPTZ,
ALTER COLUMN end_date type TIMESTAMPTZ;
*/

alter table stats.active_call_customer_accounts ALTER COLUMN created_at TYPE TIMESTAMPTZ;
alter table stats.active_call_customer_accounts_hourly ALTER COLUMN created_at TYPE TIMESTAMPTZ,
ALTER COLUMN calls_time TYPE TIMESTAMPTZ;

alter table stats.active_call_orig_gateways ALTER COLUMN created_at TYPE TIMESTAMPTZ;
alter table stats.active_call_orig_gateways_hourly ALTER COLUMN created_at TYPE TIMESTAMPTZ,
ALTER COLUMN calls_time TYPE TIMESTAMPTZ;

alter table stats.active_call_term_gateways ALTER COLUMN created_at TYPE TIMESTAMPTZ;
alter table stats.active_call_term_gateways_hourly ALTER COLUMN created_at TYPE TIMESTAMPTZ,
ALTER COLUMN calls_time TYPE TIMESTAMPTZ;

alter table stats.active_call_vendor_accounts ALTER COLUMN created_at TYPE TIMESTAMPTZ;
alter table stats.active_call_vendor_accounts_hourly ALTER COLUMN created_at TYPE TIMESTAMPTZ,
ALTER COLUMN calls_time TYPE TIMESTAMPTZ;


alter table stats.active_calls ALTER COLUMN created_at TYPE TIMESTAMPTZ;
alter table stats.active_calls_hourly ALTER COLUMN created_at TYPE TIMESTAMPTZ,
ALTER COLUMN calls_time TYPE TIMESTAMPTZ;



ALTER TABLE stats.traffic_customer_accounts ALTER COLUMN timestamp TYPE TIMESTAMPTZ;
ALTER TABLE stats.traffic_vendor_accounts ALTER COLUMN timestamp TYPE TIMESTAMPTZ;

alter TABLE sys.version ALTER COLUMN apply_date TYPE TIMESTAMPTZ;

commit;