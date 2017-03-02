begin;
insert into sys.version(number,comment) values(37,'API log');

ALTER TABLE class4.dialpeers add created_at timestamptz not null DEFAULT now();

ALTER TABLE class4.dialpeers add short_calls_limit real not null default 1;
ALTER TABLE data_import.import_dialpeers add short_calls_limit real not null default 1;

ALTER TABLE sys.guiconfig
  add short_call_length integer not null default 15,
  add termination_stats_window integer not null default 24;

commit;