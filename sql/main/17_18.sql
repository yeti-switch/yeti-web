begin;

insert into sys.version(number,comment) values(18,'new jobs');

insert into sys.jobs (type) values ('StatsClean');
insert into sys.jobs (type) values ('StatsAggregation');

commit;
