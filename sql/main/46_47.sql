begin;
insert into sys.version(number,comment) values(47,'Timezones');

CREATE TABLE sys.timezones(
  id serial primary key,
  name varchar unique not null,
  description varchar
);

INSERT INTO sys.timezones (name) SELECT  abbrev from (
  SELECT distinct abbrev from pg_timezone_names
                                                      )h order by abbrev='UTC' desc, abbrev;

ALTER TABLE billing.accounts add timezone_id integer not null default 1;

commit;