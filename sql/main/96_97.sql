begin;
insert into sys.version(number,comment) values(97,'Check vendor for dialpeers');

ALTER TABLE class4.dialpeer_next_rates
  add constraint "dialpeer_next_rate_positive_next_interval" CHECK (next_interval > 0),
  add constraint "dialpeer_next_rate_positive_initial_interval" CHECK (next_interval > 0);

commit;