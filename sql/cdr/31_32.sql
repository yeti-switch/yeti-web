begin;
insert into sys.version(number,comment) values(32,'Invoices refactoring');


ALTER TABLE billing.invoice_destinations add successful_calls_count bigint,
    add first_successful_call_at TIMESTAMPTZ,
    add last_successful_call_at TIMESTAMPTZ;

alter table billing.invoices add first_successful_call_at TIMESTAMPTZ,
    add last_successful_call_at TIMESTAMPTZ,
    add successful_calls_count bigint;

alter table billing.invoices RENAME COLUMN first_call_date to first_call_at;
alter table billing.invoices rename column last_call_date to last_call_at;

ALTER TABLE billing.invoice_documents add xls_data bytea;

commit;