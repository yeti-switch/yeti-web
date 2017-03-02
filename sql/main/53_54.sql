begin;
insert into sys.version(number,comment) values(54,'Rate versions for dialpeers');
alter table class4.dialpeer_next_rates add external_id bigint;
commit;