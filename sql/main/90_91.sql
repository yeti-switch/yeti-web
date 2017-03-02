begin;
insert into sys.version(number,comment) values(91,'Fake 180 timer');

alter table class4.gateways add fake_180_timer smallint;

commit;