begin;
insert into sys.version(number,comment) values(47,'Additional invoice grouping');

create table billing.invoice_networks (
  id bigserial PRIMARY KEY,
  country_id integer,
  network_id integer,
  rate NUMERIC,
  calls_count bigint,
  calls_duration bigint,
  amount numeric,
  invoice_id integer not null REFERENCES billing.invoices(id),
  first_call_at timestamp with time zone,
  last_call_at timestamp with time zone,
  successful_calls_count bigint,
  first_successful_call_at timestamp with time zone,
  last_successful_call_at timestamp with time zone
);

commit;