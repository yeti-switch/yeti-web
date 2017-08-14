begin;
insert into sys.version(number,comment) values(114,'allow shared gateways');

ALTER TABLE class4.gateways add is_shared boolean not null default false;
ALTER TABLE data_import.import_gateways  add is_shared boolean;

commit;