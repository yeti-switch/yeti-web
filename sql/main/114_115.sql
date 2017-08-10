begin;
insert into sys.version(number,comment) values(115,'number length limiting');

ALTER TABLE class4.customers_auth
  add min_dst_number_length smallint not null default 0,
  add max_dst_number_length smallint not null default 100;

alter table class4.customers_auth add CONSTRAINT "customers_auth_min_dst_number_length" check (min_dst_number_length>=0);
alter table class4.customers_auth add CONSTRAINT "customers_auth_max_dst_number_length" check (min_dst_number_length>=0);

ALTER TABLE data_import.import_customers_auth
  add min_dst_number_length smallint,
  add max_dst_number_length smallint;


commit;