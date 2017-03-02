begin;
insert into sys.version(number,comment) values(24,'PDF document storage');

ALTER TABLE  billing.invoice_documents add pdf_data bytea, add csv_data bytea;

commit;
