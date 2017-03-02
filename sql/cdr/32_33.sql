begin;
insert into sys.version(number,comment) values(33,'Invoice types');

create TABLE  billing.invoice_types(
  id smallint primary key,
  name varchar not null unique
);

insert into billing.invoice_types values(1, 'Manual');
insert into billing.invoice_types values(2, 'Auto. Full period');
insert into billing.invoice_types values(3, 'Auto. Partial');

ALTER TABLE billing.invoices add type_id smallint references billing.invoice_types(id);
UPDATE billing.invoices set type_id = 1;
ALTER TABLE billing.invoices ALTER COLUMN type_id SET NOT NULL ;


commit;