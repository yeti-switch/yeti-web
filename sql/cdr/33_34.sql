begin;
insert into sys.version(number,comment) values(34,'Reports refactoring');

ALTER TABLE reports.cdr_custom_report add customer_id integer;

commit;