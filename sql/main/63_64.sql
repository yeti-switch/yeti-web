begin;
insert into sys.version(number,comment) values(64,'Yet another static routing');

ALTER TABLE gui.versions add txid bigint default txid_current();

alter table class4.destinations
  add asr_limit real not null default 0,
  add acd_limit real not null default 0,
  add short_calls_limit real not null DEFAULT 0,
  add quality_alarm boolean not null default false;

ALTER TABLE class4.routing_plan_static_routes add network_prefix_id integer;

ALTER TABLE sys.api_log_config ALTER COLUMN debug set DEFAULT false;

INSERT INTO sys.api_log_config(controller) VALUES ('Api::Rest::Private::DestinationsController');
INSERT INTO sys.api_log_config(controller) VALUES ('Api::Rest::Private::DialpeerNextRatesController');
INSERT INTO sys.api_log_config(controller) VALUES ('Api::Rest::Private::DialpeersController');
INSERT INTO sys.api_log_config(controller) VALUES ('Api::Rest::Private::RateplansController');
INSERT INTO sys.api_log_config(controller) VALUES ('Api::Rest::Private::RoutingGroupsController');

commit;
