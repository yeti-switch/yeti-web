begin;
insert into sys.version(number,comment) values(17,'Extended contractor information');

alter table public.contractors
  add description varchar,
  add address varchar,
  add phones varchar,
  add tech_contact varchar,
  add fin_contact varchar;

alter table data_import.import_contractors
add description varchar,
add address varchar,
add phones varchar,
add tech_contact varchar,
add fin_contact varchar;

create table billing.invoice_periods(
id smallserial PRIMARY  key,
name varchar not null unique
);

insert into billing.invoice_periods(name) VALUES ('Daily');
insert into billing.invoice_periods(name) VALUES ('Weekly');
insert into billing.invoice_periods(name) VALUES ('Twice per month');
insert into billing.invoice_periods(name) VALUES ('Monthly');

alter table billing.accounts
  add invoice_period_id SMALLINT REFERENCES billing.invoice_periods(id),
  add autogenerate_vendor_invoices BOOLEAN not null DEFAULT false,
  add autogenerate_customer_invoices BOOLEAN not null DEFAULT false;

alter table data_import.import_accounts
  add invoice_period_id SMALLINT,
  add invoice_period_name varchar,
  add autogenerate_vendor_invoices BOOLEAN not null DEFAULT false,
  add autogenerate_customer_invoices BOOLEAN not null DEFAULT false;

commit;