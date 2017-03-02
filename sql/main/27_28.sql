begin;
insert into sys.version(number,comment) values(28,'Invoices autogeneration');

UPDATE billing.invoice_periods set name ='BiWeekly' where name='Twice per month';
INSERT INTO sys.jobs (type ) VALUES ('Invoice');

/*
alter table class4.destinations add country_id integer,
    add network_id integer;

alter table class4.dialpeers add country_id integer,
add network_id integer;

*/

commit;