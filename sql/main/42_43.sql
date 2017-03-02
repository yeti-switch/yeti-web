begin;
insert into sys.version(number,comment) values(43,'Notifications');


ALTER TABLE class4.gateways ALTER COLUMN acd_limit SET DEFAULT 0 ;
UPDATE class4.gateways set acd_limit =0 where acd_limit is null;
ALTER TABLE class4.gateways ALTER COLUMN acd_limit SET NOT NULL ;

UPDATE class4.gateways set asr_limit =0 where asr_limit is null;
ALTER TABLE class4.gateways ALTER COLUMN asr_limit SET NOT NULL ;
ALTER TABLE class4.gateways ALTER COLUMN asr_limit SET DEFAULT 0;

ALTER TABLE class4.gateways add short_calls_limit real not null default 1;

--INSERT INTO sys.jobs (type) VALUES ('TerminationQualityCheck');

ALTER TABLE sys.guiconfig add quality_control_min_calls integer not null default 100;
ALTER TABLE sys.guiconfig add quality_control_min_duration integer not null default 3600;

commit;