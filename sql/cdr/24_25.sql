begin;
insert into sys.version(number,comment) values(25,'Statistic fix');

ALTER TABLE stats.termination_quality_stats ALTER COLUMN dialpeer_id DROP NOT NULL ;
ALTER TABLE stats.termination_quality_stats ALTER COLUMN gateway_id DROP NOT NULL ;

commit;
