begin;
insert into sys.version(number,comment) values(81,'Change default log level');

ALTER TABLE class4.customers_auth ALTER COLUMN dump_level_id set DEFAULT 0;

commit;