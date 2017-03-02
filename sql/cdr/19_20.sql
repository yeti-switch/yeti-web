begin;
insert into sys.version(number,comment) values(20,'Schedulers for reports');

create table reports.scheduler_periods(
  id SMALLINT PRIMARY KEY ,
  name varchar not null UNIQUE
);

insert into reports.scheduler_periods(id,name) VALUES (1,'Hourly');
insert into reports.scheduler_periods(id,name) VALUES (2,'Daily');
insert into reports.scheduler_periods(id,name) VALUES (3,'Weekly');
insert into reports.scheduler_periods(id,name) VALUES (4,'BiWeekly');
insert into reports.scheduler_periods(id,name) VALUES (5,'Monthly');

create table reports.customer_traffic_report_schedulers(
  id serial PRIMARY KEY ,
  created_at TIMESTAMPTZ,
  period_id integer not null REFERENCES reports.scheduler_periods(id),
  customer_id INTEGER not null,
  send_to int[],
  last_run_at TIMESTAMPTZ,
  next_run_at TIMESTAMPTZ
);

create table reports.vendor_traffic_report_schedulers(
  id serial PRIMARY KEY ,
  created_at TIMESTAMPTZ,
  period_id integer not null REFERENCES reports.scheduler_periods(id),
  vendor_id INTEGER not null,
  send_to int[],
  last_run_at TIMESTAMPTZ,
  next_run_at TIMESTAMPTZ
);

create table reports.cdr_custom_report_schedulers(
  id serial PRIMARY KEY ,
  created_at TIMESTAMPTZ,
  period_id integer not null REFERENCES reports.scheduler_periods(id),
  filter varchar,
  group_by varchar[],
  send_to int[],
  last_run_at TIMESTAMPTZ,
  next_run_at TIMESTAMPTZ
);

create table reports.cdr_interval_report_schedulers(
  id serial PRIMARY KEY ,
  created_at TIMESTAMPTZ,
  period_id integer not null REFERENCES reports.scheduler_periods(id),
  filter varchar,
  group_by varchar[],
  interval_length integer,
  aggregator_id integer,
  aggregate_by varchar,
  send_to int[],
  last_run_at TIMESTAMPTZ,
  next_run_at TIMESTAMPTZ
);

commit;