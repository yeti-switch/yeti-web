begin;
insert into sys.version(number,comment) values(65,'Ringing timeout disconnect code');

INSERT INTO class4.disconnect_code(id,namespace_id,stop_hunting,code,reason) VALUES(1505,1,FALSE,487,'Ringing timeout');

ALTER TABLE class4.gateways add force_one_way_early_media boolean not null default false;


INSERT INTO notifications.alerts (event) VALUES ('DestinationQualityAlarmFired');
INSERT INTO notifications.alerts (event) VALUES ('DestinationQualityAlarmCleared');


ALTER TABLE class4.rateplans add send_quality_alarms_to integer[];

commit;