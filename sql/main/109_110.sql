begin;
insert into sys.version(number,comment) values(110,'Destinations import fix');

alter table data_import.import_destinations
  add column asr_limit real,
  add column acd_limit real,
  add column short_calls_limit real;

commit;