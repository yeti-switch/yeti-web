begin;
drop schema reports cascade;
insert into sys.version(number,comment) values(12,'Traffic reports moved to CDR database');
commit;
