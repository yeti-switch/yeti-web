begin;
insert into sys.version(number,comment) values(49,'Payments refactoring');


DROP FUNCTION billing.payment_add(integer, numeric, character varying);

ALTER TABLE sys.timezones
  add abbrev varchar,
  add utc_offset interval,
  add is_dst boolean;
ALTER TABLE sys.timezones DROP COLUMN description ;

/* load new timezones from PG */

delete from sys.timezones;
SELECT setval('sys.timezones_id_seq',1,false);
INSERT INTO sys.timezones (name,abbrev,utc_offset,is_dst) SELECT name,abbrev,utc_offset,is_dst from pg_timezone_names() order by name='UTC' desc, name;

ALTER TABLE billing.accounts add constraint "accounts_timezone_id_fkey" foreign key (timezone_id) references sys.timezones(id);
commit;