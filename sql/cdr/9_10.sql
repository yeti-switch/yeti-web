begin;
insert into sys.version(number,comment) values(10,'Call statistic aggregation');

create table stats.active_calls_hourly(
  id bigserial primary key,
  node_id integer not null,
  max_count integer not null,
  avg_count real not null,
  min_count integer not null,
  created_at timestamp not null,
  calls_time TIMESTAMP not null
);

create table stats.active_call_orig_gateways_hourly(
  id bigserial primary key,
  gateway_id integer not null,
  max_count integer not null,
  avg_count real not null,
  min_count integer not null,
  created_at timestamp not null,
  calls_time TIMESTAMP not null
);

create table stats.active_call_term_gateways_hourly(
  id bigserial primary key,
  gateway_id integer not null,
  max_count integer not null,
  avg_count real not null,
  min_count integer not null,
  created_at timestamp not null,
  calls_time TIMESTAMP not null
);

create table stats.active_call_customer_accounts_hourly(
  id bigserial primary key,
  account_id integer not null,
  max_count integer not null,
  avg_count real not null,
  min_count integer not null,
  created_at timestamp not null,
  calls_time TIMESTAMP not null
);

create table stats.active_call_vendor_accounts_hourly(
  id bigserial primary key,
  account_id integer not null,
  max_count integer not null,
  avg_count real not null,
  min_count integer not null,
  created_at timestamp not null,
  calls_time TIMESTAMP not null
);

commit;