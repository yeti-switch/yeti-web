begin;
insert into sys.version(number,comment) values(16,'Added job for CallMonitoring');

insert into sys.jobs(type) values('CallsMonitoring');

commit;