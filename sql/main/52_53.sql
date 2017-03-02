begin;
insert into sys.version(number,comment) values(53,'Rate versions for dialpeers');

alter table data_import.import_destinations add network_prefix_id integer;

INSERT INTO sys.jobs (type) VALUES ('DialpeerRatesApply');

alter table class4.dialpeers add current_rate_id bigint;

create table class4.dialpeer_next_rates(
  id bigserial primary key,
  dialpeer_id bigint not null,
  rate numeric not null,
  initial_interval smallint not null,
  next_interval smallint not null,
  connect_fee numeric not null,
  apply_time timestamptz not null,
  created_at timestamptz not null,
  updated_at timestamptz,
  applied boolean not null default false
);

ALTER TABLE class4.dialpeers add external_id bigint;
CREATE INDEX ON class4.dialpeers USING btree (external_id);

commit;