begin;
insert into sys.version(number,comment) values(57,'external_id for destinations');

alter table class4.destinations add external_id bigint;

commit;
