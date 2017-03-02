begin;
insert into sys.version(number,comment) values(37,'fix types');

ALTER TABLE reports.customer_traffic_report_data_by_destination ALTER COLUMN success_calls_count TYPE bigint;
ALTER TABLE reports.customer_traffic_report_data_by_vendor ALTER COLUMN success_calls_count TYPE bigint;
ALTER TABLE reports.customer_traffic_report_data_full ALTER COLUMN success_calls_count TYPE bigint;

commit;
