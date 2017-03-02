begin;
insert into sys.version(number,comment) values(35,'Reports schedulers fix');

ALTER TABLE reports.cdr_custom_report_schedulers add customer_id integer;

commit;