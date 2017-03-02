begin;
insert into sys.version(number,comment) values(30,'Reports refactoring');

DROP FUNCTION reports.customer_traffic_report(integer);
DROP FUNCTION reports.vendor_traffic_report(integer);
DROP FUNCTION reports.cdr_custom_report(integer);

commit;